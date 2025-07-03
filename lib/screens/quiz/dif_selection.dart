import 'package:eng_quiz_app/screens/quiz/quiz.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DifficultySelectionPage extends StatelessWidget {
  const DifficultySelectionPage({super.key});

  Future<List<Map<String, dynamic>>> fetchQuestions(String difficulty) async {
    try {
      final DatabaseReference difficultyRef =
          FirebaseDatabase.instance.ref().child('questions').child(difficulty);

      final snapshot = await difficultyRef.get();

      List<Map<String, dynamic>> questions = [];
      if (snapshot.exists) {
        for (var child in snapshot.children) {
          final question = Map<String, dynamic>.from(child.value as Map);
          questions.add(question);
        }
        questions.shuffle();
      }
      return questions;
    } catch (e) {
      print("Sorular yüklenirken hata: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(colors: [
          const Color.fromARGB(255, 97, 64, 153),
          Colors.deepPurple.shade900,
        ])),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        "Seviyenizi seçiniz",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDifficultyButton(context, 'A1 - A2', 'easy'),
                        const SizedBox(height: 20),
                        _buildDifficultyButton(context, 'B1 - B2', 'medium'),
                        const SizedBox(height: 20),
                        _buildDifficultyButton(context, 'C1 - C2', 'hard'),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
      BuildContext context, String label, String difficulty) {
    return ElevatedButton(
      onPressed: () async {
        List<Map<String, dynamic>> questions = await fetchQuestions(difficulty);

        if (questions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu zorluk seviyesinde soru bulunamadı!'),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPage(
              questions: questions,
              difficulty: label,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.deepPurple,
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 25, color: Colors.white)),
    );
  }
}
