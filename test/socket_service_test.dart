import 'dart:async';
import 'dart:typed_data';

import 'package:Snapdrop/services/socket_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake of the transport so the transfer flow + ack handling can be
/// tested without a real socket server (P1-7 enables this).
class FakeSocketTransport implements SocketTransport {
  final _controller = StreamController<bool>.broadcast();
  final List<Map<String, dynamic>> sent = [];

  @override
  void connectToSocketServer() {}

  @override
  void sendImages(
      {String? name, String? type, Uint8List? file, String? userId}) {
    sent.add({'name': name, 'type': type, 'userId': userId, 'bytes': file});
  }

  @override
  Stream<bool> imageReceivedStream() => _controller.stream;

  void emitAck() => _controller.add(true);

  @override
  String? get userId => 'fake-user';
  @override
  String? get roomId => 'fake-room';
  @override
  Future<Uint8List?> fileToBuffer(String filePath) async => Uint8List(0);
  @override
  Future<void> dispose() async => _controller.close();
}

void main() {
  group('SocketService.parseRoomId', () {
    test('extracts room from a valid pairing QR', () {
      expect(SocketService.parseRoomId('https://getsnapdrop.in/?room=abc123'),
          'abc123');
    });

    test('returns null for a QR with no "="', () {
      expect(SocketService.parseRoomId('not-a-pairing-qr'), isNull);
    });

    test('returns null for a QR with multiple "="', () {
      expect(SocketService.parseRoomId('a=b=c'), isNull);
    });
  });

  group('ack stream contract', () {
    test('imageReceivedStream is broadcast (supports multiple listeners)',
        () async {
      final t = FakeSocketTransport();
      final a = <bool>[];
      final b = <bool>[];
      t.imageReceivedStream().listen(a.add);
      t.imageReceivedStream().listen(b.add);

      t.emitAck();
      await Future<void>.delayed(Duration.zero);

      expect(a, [true]);
      expect(b, [true]);
      await t.dispose();
    });

    test('sendImages forwards name/type/userId payload', () {
      final t = FakeSocketTransport();
      t.sendImages(name: 'pic', type: 'png', userId: 'u1', file: Uint8List(3));
      expect(t.sent.single['name'], 'pic');
      expect(t.sent.single['type'], 'png');
      expect(t.sent.single['userId'], 'u1');
    });
  });
}
