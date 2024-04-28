import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  final String _url;
  String? _userId;
  String? _roomId;
  SocketService({required String url}) : _url = url;
  io.Socket? socket;

  void connectToSocketServer() {
    _socketConnection();
    _onConnectChecker();
    _testMessage();
    _onConnectErrorChecker();
    _fetchUserId();
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

  Future<bool> transferCompleted() async {
    Completer<bool> completer = Completer<bool>();

    socket!.on('image_received_to_figma', (data) {
      completer.complete(true);
    });

    return completer.future;
  }

  String? get userId => _userId;

  String? get roomId => _roomId;

  Future<String?> fetchUserId() async {
    await Future.delayed(const Duration(microseconds: 1));
    return _userId;
  }

  Future<Uint8List?> fileToBuffer(String filePath) async {
    File file = File(filePath);

    try {
      Uint8List buffer = await file.readAsBytes();
      return buffer;
    } catch (e) {
      log('Error reading file: $e');
      return null;
    }
  }
}
