import 'package:flutter/material.dart';

class StatisticCard extends StatelessWidget {
  final int dogru;
  final int yanlis;

  const StatisticCard({
    super.key,
    required this.dogru,
    required this.yanlis,
  });

  @override
  Widget build(BuildContext context) {
    int total = dogru + yanlis;
    double dogruRate = total > 0 ? (dogru / total) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildColumn("Doğru", dogru.toString()),
          Container(
            height: 50,
            width: 1,
            color: Colors.black,
          ),
          _buildColumn("Yanlış", yanlis.toString()),
          Container(
            height: 50,
            width: 1,
            color: Colors.black,
          ),
          _buildColumn("Doğru oranı", "%${dogruRate.toStringAsFixed(0)}"),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
