import 'package:eng_quiz_app/models/users.dart';
import 'package:eng_quiz_app/screens/home_page.dart';
import 'package:eng_quiz_app/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
  Future<Users> fetchUserFromDatabase(String uid) async {
    final databaseRef = FirebaseDatabase.instance.ref('users/$uid');
    final snapshot = await databaseRef.get();

    if (snapshot.exists) {
      return Users.fromJson(uid,
          Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>));
    } else {
      throw Exception('Kullanıcı bulunamadı');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Hata"),
            );
          } else {
            final user = snapshot.data;
            if (user != null) {
              return FutureBuilder<Users>(
                future: fetchUserFromDatabase(user.uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return const Center(child: Text("Hata oluştu!"));
                  } else if (userSnapshot.hasData) {
                    return HomePage(user: userSnapshot.data!);
                  }
                  return const LoginPage();
                },
              );
            }
            return const LoginPage();
          }
        },
      ),
    );
  }
}
