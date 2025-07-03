import 'package:flutter/material.dart';

class BoardCard extends StatelessWidget {
  final String username;
  final String avatar;
  final int userRank;
  final int score;
  final Color color;
  const BoardCard(
      {super.key,
      required this.username,
      required this.avatar,
      required this.userRank,
      required this.score,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "#$userRank",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundImage: AssetImage(avatar),
              ),
            ],
          ),
          title: Text(username),
          trailing: Text(
            "$score",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
