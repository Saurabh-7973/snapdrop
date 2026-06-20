import 'dart:async';
import 'package:flutter/foundation.dart';

import 'socket_service.dart';

enum SessionStatus { disconnected, pairing, connected, transferring, lost }

/// App-level owner of the pairing/transfer socket. Hoisted out of the screens
/// so a session survives picker <-> transfer navigation: scan once, then send
/// many times over the SAME socket (no re-scan). Plain ChangeNotifier — no new
/// dependency. Accessed via the [sessionController] singleton; widgets that
/// react wrap in ListenableBuilder.
///
/// The wire contract (SocketService emit/events/payload) is FROZEN and unchanged
/// here — this only governs the socket's lifecycle and reuse.
class SessionController extends ChangeNotifier {
  SessionStatus _status = SessionStatus.disconnected;
  SocketService? _socket;
  String? _roomId;
  DateTime? _connectedAt;
  bool _reconnectTried = false;

  SessionStatus get status => _status;
  SocketService? get socket => _socket;
  String? get roomId => _roomId;
  String? get selfId => _socket?.userId;
  DateTime? get connectedAt => _connectedAt;

  bool get isConnected =>
      _status == SessionStatus.connected ||
      _status == SessionStatus.transferring;

  /// Short room id for the connection indicator.
  String get shortRoomId {
    final r = _roomId ?? '';
    return r.length <= 8 ? r : r.substring(0, 8);
  }

  void _set(SessionStatus s) {
    if (_status == s) return;
    _status = s;
    notifyListeners();
  }

  /// Pair from a scanned QR. Creates + connects the socket once, then holds it.
  /// [qrCode] is the raw QR payload (`...=room`).
  void pair(String qrCode) {
    final room = SocketService.parseRoomId(qrCode);
    if (room == null) return; // caller already guards invalid QR
    _roomId = room;
    _reconnectTried = false;
    _set(SessionStatus.pairing);

    _socket?.dispose();
    _socket = SocketService(url: qrCode);
    _socket!.connectToSocketServer();
    _socket!.onDropped = onSocketDropped;
    _connectedAt = DateTime.now();
    _set(SessionStatus.connected);
  }

  void markTransferring() {
    if (_socket != null) _set(SessionStatus.transferring);
  }

  /// Transfer acked complete — keep the session live for the next send.
  void markComplete() {
    if (_socket != null) _set(SessionStatus.connected);
  }

  /// A real end: explicit Close/Disconnect, plugin close, or fatal drop.
  Future<void> disconnect() async {
    await _socket?.dispose();
    _socket = null;
    _roomId = null;
    _connectedAt = null;
    _set(SessionStatus.disconnected);
  }

  /// Socket dropped unexpectedly. Try one silent reconnect to the same room;
  /// if it fails, surface the lost state.
  void onSocketDropped() {
    if (_socket == null || _roomId == null) {
      _set(SessionStatus.lost);
      return;
    }
    if (_reconnectTried) {
      _set(SessionStatus.lost);
      return;
    }
    _reconnectTried = true;
    final url = _socket!.url;
    _socket?.dispose();
    _socket = SocketService(url: url);
    _socket!.connectToSocketServer();
    _socket!.onDropped = onSocketDropped;
    _set(SessionStatus.connected);
  }
}

/// Single app-wide instance (matches the codebase's static-service style).
final SessionController sessionController = SessionController();
