import 'package:flutter/material.dart';

/// Paired-session display — two stacked pairs (green dot + small-caps label +
/// mono session id), centered. Matches snapdrop_transfer_faithful.html.
class RoomDisplayer extends StatelessWidget {
  final String senderId;
  final String receiverId;
  final String senderMessage;
  final String receiverMessage;

  const RoomDisplayer({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.senderMessage,
    required this.receiverMessage,
  });

  Widget _pair(String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF46C886),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF46C886).withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF8FA89A),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFFEEF1EF),
            fontSize: 13.5,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _pair(receiverMessage, receiverId),
        const SizedBox(height: 16),
        _pair(senderMessage, senderId),
      ],
    );
  }
}
