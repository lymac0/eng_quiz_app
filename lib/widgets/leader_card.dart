import 'package:flutter/material.dart';

class LeaderCardWidget extends StatelessWidget {
  final String avatar;
  final int score;
  final int rank;
  final String username;
  const LeaderCardWidget(
      {super.key,
      required this.avatar,
      required this.score,
      required this.rank,
      required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Text(
              "$rank",
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 6
                    ..color = Colors.grey.shade700),
            ),
            Text(
              "$rank",
              style: const TextStyle(fontSize: 23, color: Colors.white),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(avatar),
            ),
            const SizedBox(
              height: 90,
              child: Image(image: AssetImage("assets/images/frame.png")),
            ),
          ],
        ),
        Text(
          username,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        Text(
          "$score",
          style: const TextStyle(
              fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
