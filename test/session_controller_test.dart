import 'package:flutter_test/flutter_test.dart';
import 'package:Snapdrop/services/session_controller.dart';

void main() {
  group('SessionController persistent session', () {
    test('starts disconnected', () {
      final s = SessionController();
      expect(s.status, SessionStatus.disconnected);
      expect(s.isConnected, false);
      expect(s.roomId, isNull);
    });

    test('pair() goes connected and holds the room (scan once)', () {
      final s = SessionController();
      s.pair('wss://host?room=ABC123XYZ');
      expect(s.status, SessionStatus.connected);
      expect(s.isConnected, true);
      expect(s.roomId, 'ABC123XYZ');
      expect(s.shortRoomId, 'ABC123XY'); // first 8
      s.disconnect();
    });

    test('invalid QR does not pair', () {
      final s = SessionController();
      s.pair('no-equals-here');
      expect(s.status, SessionStatus.disconnected);
      expect(s.isConnected, false);
    });

    test('transfer keeps session live for the next send (no re-scan)', () {
      final s = SessionController();
      s.pair('x=ROOM1');
      s.markTransferring();
      expect(s.status, SessionStatus.transferring);
      expect(s.isConnected, true); // still usable
      s.markComplete();
      expect(s.status, SessionStatus.connected); // ready to send again
      s.disconnect();
    });

    test('disconnect tears everything down', () async {
      final s = SessionController();
      s.pair('x=ROOM2');
      await s.disconnect();
      expect(s.status, SessionStatus.disconnected);
      expect(s.socket, isNull);
      expect(s.roomId, isNull);
    });

    test('socket drop -> one silent reconnect, second drop -> lost', () {
      final s = SessionController();
      s.pair('x=ROOM3');
      s.onSocketDropped(); // first drop: silent reconnect
      expect(s.status, SessionStatus.connected);
      s.onSocketDropped(); // second drop: give up
      expect(s.status, SessionStatus.lost);
      expect(s.isConnected, false);
      s.disconnect();
    });

    test('notifies listeners on transition', () {
      final s = SessionController();
      var n = 0;
      s.addListener(() => n++);
      s.pair('x=ROOMN');
      expect(n, greaterThan(0));
      s.disconnect();
    });
  });
}
