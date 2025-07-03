import 'dart:async';
import 'package:eng_quiz_app/screens/quiz/end_screen.dart';
import 'package:eng_quiz_app/widgets/option_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String difficulty;

  const QuizPage(
      {super.key, required this.questions, required this.difficulty});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

const int maxTime = 60;
const int correctAnswerTimeBonus = 2;
const int wrongAnswerTimePenalty = 5;

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  int sessionScore = 0;
  int timeLeft = maxTime;
  int delay = 1;
  Timer? timer;

  String? selectedAnswer;
  bool showCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    try {
      startTimer();
      _fetchUserScore();
    } catch (e) {
      print('InitState işleminde hata: $e');
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        _showQuizEndDialog();
      }
    });
  }

  Future<void> _fetchUserScore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ref =
            FirebaseDatabase.instance.ref().child('users').child(user.uid);
        final snapshot = await ref.child('score').get();
        if (snapshot.exists) {
          setState(() {
            score = int.parse(snapshot.value.toString());
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Hata: $e');
    }
  }

  Future<void> _updateUserScore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ref =
            FirebaseDatabase.instance.ref().child('users').child(user.uid);
        final snapshot = await ref.child('username').get();
        if (snapshot.exists) {
          final username = snapshot.value as String;
          final statsRef = FirebaseDatabase.instance
              .ref()
              .child('userstats')
              .child(username);
          await statsRef.update({'score': score + sessionScore});
          await ref.update({'score': score + sessionScore});
          setState(() {
            sessionScore = 0;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Hata: $e');
    }
  }

  int correctAnswersCount = 0;
  int incorrectAnswersCount = 0;

  int point(String difficulty) {
    if (difficulty == "A1 - A2") {
      return 2;
    } else if (difficulty == "B1 - B2") {
      return 4;
    } else {
      return 6;
    }
  }

  void _answerQuestion(String selectedAnswer) {
    final currentQuestion = widget.questions[currentQuestionIndex];
    setState(() {
      this.selectedAnswer = selectedAnswer;
      if (selectedAnswer == currentQuestion['answer']) {
        correctAnswersCount++;
        sessionScore += point(widget.difficulty);
        timeLeft = (timeLeft + correctAnswerTimeBonus).clamp(0, maxTime);
      } else {
        incorrectAnswersCount++;
        timeLeft = (timeLeft - wrongAnswerTimePenalty).clamp(0, maxTime);
      }
    });

    Future.delayed(Duration(seconds: delay), _goToNextQuestion);
  }

  void _goToNextQuestion() {
    if (!mounted) return;
    if (timeLeft <= 0) {
      _showQuizEndDialog();
      return;
    }
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    } else {
      _showQuizEndDialog();
    }
  }

  void _showQuizEndDialog() {
    _updateUserScore();
    timer?.cancel();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EndScreen(
            dogru: correctAnswersCount,
            yanlis: incorrectAnswersCount,
            sessionScore: sessionScore,
          ),
        ));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    try {
      timer?.cancel();
      super.dispose();
    } catch (e) {
      print('Dispose işleminde hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[currentQuestionIndex];
    final correctAnswer = currentQuestion['answer'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [
            const Color.fromARGB(255, 97, 64, 153),
            Colors.deepPurple.shade900,
          ]),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.difficulty,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: CircularProgressIndicator(
                                  value: (timeLeft / maxTime).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey.shade800,
                                  color: Colors.green,
                                  strokeWidth: 6,
                                ),
                              ),
                              Text(
                                '$timeLeft',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text('Süre',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Puan:',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                          Text(
                            '$sessionScore',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Soru index ve soru metni
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                Text(
                                  '${currentQuestionIndex + 1}.',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  currentQuestion['question'],
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.indigo.shade900,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              currentQuestion['options'].length,
                              (index) {
                                final option =
                                    currentQuestion['options'][index];

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: SizedBox(
                                    width: 250,
                                    child: OptionButton(
                                      option: option,
                                      correctAnswer: correctAnswer,
                                      selectedAnswer: selectedAnswer,
                                      onPressed: (selectedAnswer == null &&
                                              !showCorrectAnswer)
                                          ? () => _answerQuestion(option)
                                          : () {},
                                    ),
                                  ),
                                );
                              },
                            )),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
