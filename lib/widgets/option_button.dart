import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String option;
  final String correctAnswer;
  final String? selectedAnswer;
  final VoidCallback onPressed;

  const OptionButton({
    super.key,
    required this.option,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.onPressed,
  });

  Color _getButtonColor() {
    if (selectedAnswer == null) return Colors.white;
    if (option == correctAnswer) return Colors.green;
    if (option == selectedAnswer) return Colors.red;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getButtonColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(
        option,
        style: TextStyle(
          fontSize: 16,
          color: Colors.indigo.shade900,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
