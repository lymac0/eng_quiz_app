import 'package:eng_quiz_app/models/users.dart';
import 'package:eng_quiz_app/screens/home_page.dart';
import 'package:eng_quiz_app/widgets/board_card.dart';
import 'package:eng_quiz_app/widgets/statistic_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EndScreen extends StatelessWidget {
  final int dogru;
  final int yanlis;
  final int sessionScore;
  const EndScreen(
      {super.key,
      required this.dogru,
      required this.yanlis,
      required this.sessionScore});

  Future<int> getUserRank(String userId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref('users')
        .orderByChild('score')
        .get();
    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      final usersList = data.entries
          .map((e) => Users.fromJson(e.key, Map<String, dynamic>.from(e.value)))
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));

      for (int i = 0; i < usersList.length; i++) {
        if (usersList[i].uid == userId) {
          return i + 1;
        }
      }
    }

    return -1;
  }

  Future<Users> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ref =
            FirebaseDatabase.instance.ref().child('users').child(user.uid);
        final snapshot = await ref.get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          return Users.fromJson(user.uid, data);
        } else {
          throw Exception("Kullanıcı verisi bulunamadı.");
        }
      } else {
        throw Exception("Kullanıcı oturumu açık değil.");
      }
    } catch (e) {
      throw Exception("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        leadingWidth: 75,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 30,
            )),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Users>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color.fromARGB(255, 97, 64, 153),
                      Colors.deepPurple.shade900,
                    ],
                  ),
                ),
                child: const Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Kullanıcı verisi bulunamadı."));
          }

          final user = snapshot.data!;
          return FutureBuilder<int>(
            future: getUserRank(user.uid),
            builder: (context, rankSnapshot) {
              if (rankSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color.fromARGB(255, 97, 64, 153),
                          Colors.deepPurple.shade900,
                        ],
                      ),
                    ),
                    child: const Center(child: CircularProgressIndicator()));
              } else if (rankSnapshot.hasError) {
                return Center(child: Text("Hata: ${rankSnapshot.error}"));
              } else if (!rankSnapshot.hasData || rankSnapshot.data == -1) {
                return const Center(
                    child: Text("Kullanıcı sırası bulunamadı."));
              }

              final userRank = rankSnapshot.data!;

              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color.fromARGB(255, 97, 64, 153),
                      Colors.deepPurple.shade900,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                                child: Text(
                              "$sessionScore",
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            )),
                          ),
                          const Positioned(
                            left: -50,
                            top: -25,
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image(
                                  image: AssetImage("assets/images/star.png")),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 300,
                        child: StatisticCard(
                          dogru: dogru,
                          yanlis: yanlis,
                        ),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                          width: 300,
                          height: 90,
                          child: BoardCard(
                              color: Colors.white,
                              username: user.username,
                              avatar: user.avatar,
                              userRank: userRank,
                              score: user.score + sessionScore)),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(user: user),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              icon: const Icon(
                                Icons.home,
                                color: Colors.white,
                              ),
                              iconSize: 90,
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.replay,
                                color: Colors.white,
                              ),
                              iconSize: 90,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
