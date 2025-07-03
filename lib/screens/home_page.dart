import 'package:eng_quiz_app/models/users.dart';
import 'package:eng_quiz_app/screens/leaderboard_page.dart';
import 'package:eng_quiz_app/screens/quiz/dif_selection.dart';
import 'package:eng_quiz_app/settings/settings_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Users user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref("users");

  Stream<Map<String, dynamic>> _userStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _database.child(user.uid).onValue.map((event) {
        return event.snapshot.value != null
            ? Map<String, dynamic>.from(event.snapshot.value as Map)
            : {};
      });
    }
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
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
          child: StreamBuilder<Map<String, dynamic>>(
            stream: _userStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Hata oluştu!"));
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return const Center(child: Text("Veri bulunamadı!"));
              }

              final String avatar =
                  snapshot.data?['avatar'] ?? widget.user.avatar;
              final String username =
                  snapshot.data?['username'] ?? widget.user.username;
              final int score = snapshot.data?['score'] ?? widget.user.score;
              final int level = widget.user.level;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(clipBehavior: Clip.none, children: [
                          Positioned(
                            right: -160,
                            top: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromARGB(255, 149, 0, 255),
                                      Color.fromARGB(255, 85, 0, 146)
                                    ]),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    username,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromARGB(255, 149, 0, 255),
                                      Color.fromARGB(255, 85, 0, 146)
                                    ]),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    "Puan: $score",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: -180,
                              child: SizedBox(
                                height: 70,
                                width: 70,
                                child: Stack(
                                  children: [
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        Colors.orange.shade500,
                                        BlendMode.modulate,
                                      ),
                                      child:
                                          Image.asset("assets/images/star.png"),
                                    ),
                                    Center(
                                      child: Text(
                                        "$level",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(avatar),
                          ),
                        ]),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      child: SizedBox(
                        width: 200,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DifficultySelectionPage(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25))),
                          child: const Text(
                            "Oyunu Başlat",
                            style: TextStyle(fontSize: 23),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaderboardPage(),
                              ));
                        },
                        icon: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                        ),
                        iconSize: 90,
                      ),
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const SettingsMenu();
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        iconSize: 90,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
