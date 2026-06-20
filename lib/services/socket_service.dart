import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';

/// Abstraction over the pairing/transfer socket so the transfer flow can be
/// tested with a mock and the implementation swapped without touching widgets.
/// The wire format (event names + payload shape) is the FROZEN contract with the
/// Figma plugin — see Revival §1. Do not change it here.
abstract class SocketTransport {
  void connectToSocketServer();

  void sendImages(
      {String? name, String? type, Uint8List? file, String? userId});

  /// Emits `true` each time the plugin acknowledges an image was received.
  /// Single broadcast stream for the lifetime of the transport (no per-call
  /// controller — that previously leaked and stacked duplicate listeners).
  Stream<bool> imageReceivedStream();

  String? get userId;
  String? get roomId;

  Future<Uint8List?> fileToBuffer(String filePath);

  /// Closes the socket and the ack stream. Call when leaving the transfer flow.
  Future<void> dispose();
}

class SocketService implements SocketTransport {
  /// A valid pairing QR carries `...=<room>`. Returns the room id, or null if
  /// the QR is malformed (no single '='). Centralizes the parse rule used by
  /// the scanner guard and the join emit.
  static String? parseRoomId(String qr) {
    final parts = qr.split('=');
    return parts.length == 2 ? parts[1] : null;
  }

  final String _url;
  String? _userId;
  String? _roomId;
  SocketService({required String url}) : _url = url;
  io.Socket? socket;

  /// Raw pairing URL/QR payload this service was created from (read-only).
  String get url => _url;

  // Single broadcast controller for image-received acks (was created per call).
  final StreamController<bool> _imageReceivedController =
      StreamController<bool>.broadcast();

  @override
  void connectToSocketServer() {
    _socketConnection();
    _onConnectChecker();
    _testMessage();
    _onConnectErrorChecker();
    _fetchUserId();
    _onImageReceived();
    _joinFigmaRoom();
  }

  void _socketConnection() {
    socket = io.io('https://getsnapdrop.in/',
        OptionBuilder().setTransports(['websocket']).setTimeout(10000).build());

    socket!.connect();
  }

  void _testMessage() {
    socket!.emit('test', 'sad');
  }

  void _onConnectChecker() {
    socket!.onConnect((data) {});
  }

  void _onConnectErrorChecker() {
    socket!.on('connect_error', (error) {});
  }

  void _joinFigmaRoom() {
    _roomId = _url.toString().split('=')[1];

    socket!.emit("join_figma_room", {
      'my_id': _userId,
      'room': _roomId,
    });
  }

  void _fetchUserId() {
    socket!.on('your_id', (data) {
      _userId = data['id'];
    });
  }

  // Register the ack handler exactly once; feed the single broadcast stream.
  void _onImageReceived() {
    socket!.on('image_received_to_figma', (data) {
      if (!_imageReceivedController.isClosed) {
        _imageReceivedController.add(true);
      }
    });
  }

  @override
  void sendImages(
      {String? name, String? type, Uint8List? file, String? userId}) {
    String? imageName = name;
    String? imageType = type;

    socket!.emit("image", {
      'room': _roomId,
      'files': [
        {
          'name': imageName,
          'type': imageType,
          'file': file,
          'sender': userId,
        }
      ],
    });
  }

  @override
  Stream<bool> imageReceivedStream() => _imageReceivedController.stream;

  @override
  String? get userId => _userId ?? "";

  @override
  String? get roomId => _roomId ?? "";

  Future<String?> fetchUserId() async {
    await Future.delayed(const Duration(microseconds: 1));
    return _userId;
  }

  @override
  Future<Uint8List?> fileToBuffer(String filePath) async {
    File file = File(filePath);

    try {
      Uint8List buffer = await file.readAsBytes();
      return buffer;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    socket?.dispose();
    socket = null;
    if (!_imageReceivedController.isClosed) {
      await _imageReceivedController.close();
    }
  }
}
