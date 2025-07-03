import 'package:eng_quiz_app/models/users.dart';
import 'package:eng_quiz_app/widgets/board_card.dart';
import 'package:eng_quiz_app/widgets/leader_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  LeaderboardPage({super.key});

  final DatabaseReference _database = FirebaseDatabase.instance.ref("users");

  Stream<List<Users>> _getLeaderboard() {
    return _database.orderByChild("score").limitToLast(10).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) =>
                Users.fromJson(e.key, Map<String, dynamic>.from(e.value)))
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));
      } else {
        return [];
      }
    });
  }

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
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [
            const Color.fromARGB(255, 97, 64, 153),
            Colors.deepPurple.shade900,
          ]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Sıralama',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 5),
                StreamBuilder<List<Users>>(
                  stream: _getLeaderboard(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Bir hata oluştu!",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "Liderlik tablosu boş!",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final users = snapshot.data!;
                    final topThree = users.take(3).toList();
                    final remainingUsers = users.skip(3).toList();

                    return Column(
                      children: [
                        SizedBox(
                          height: 183,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (topThree.length > 1)
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: LeaderCardWidget(
                                      avatar: topThree[1].avatar,
                                      score: topThree[1].score,
                                      rank: 2,
                                      username: topThree[1].username,
                                    ),
                                  ),
                                ),
                              if (topThree.isNotEmpty)
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: LeaderCardWidget(
                                    avatar: topThree[0].avatar,
                                    score: topThree[0].score,
                                    rank: 1,
                                    username: topThree[0].username,
                                  ),
                                ),
                              if (topThree.length > 2)
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: LeaderCardWidget(
                                      avatar: topThree[2].avatar,
                                      score: topThree[2].score,
                                      rank: 3,
                                      username: topThree[2].username,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...remainingUsers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final user = entry.value;
                          return SizedBox(
                            height: 65,
                            child: BoardCard(
                              username: user.username,
                              avatar: user.avatar,
                              userRank: index + 4,
                              score: user.score,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 10),
                        Container(height: 1, width: 200, color: Colors.white),
                        FutureBuilder<Users>(
                          future: fetchUserData(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (userSnapshot.hasError) {
                              return const Center(
                                child: Text(
                                  "Veri yüklenemedi.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else if (userSnapshot.hasData) {
                              final currentUser = userSnapshot.data!;
                              return FutureBuilder<int>(
                                future: getUserRank(currentUser.uid),
                                builder: (context, rankSnapshot) {
                                  if (rankSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (rankSnapshot.hasError) {
                                    return Center(
                                      child:
                                          Text("Hata: ${rankSnapshot.error}"),
                                    );
                                  } else if (!rankSnapshot.hasData ||
                                      rankSnapshot.data == -1) {
                                    return const Center(
                                      child:
                                          Text("Kullanıcı sırası bulunamadı."),
                                    );
                                  }

                                  final userRank = rankSnapshot.data!;
                                  return SizedBox(
                                    height: 65,
                                    child: BoardCard(
                                      color: Colors.orange.shade400,
                                      username: currentUser.username,
                                      avatar: currentUser.avatar,
                                      userRank: userRank,
                                      score: currentUser.score,
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                child: Text(
                                  "Kullanıcı bulunamadı.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
