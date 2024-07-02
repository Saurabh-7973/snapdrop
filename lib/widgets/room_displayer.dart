import 'package:flutter/material.dart';

class RoomDisplayer extends StatelessWidget {
  String? roomId;
  String message;

  RoomDisplayer({super.key, required this.roomId, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
              height: 10,
              child: CircleAvatar(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                message,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                roomId!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
