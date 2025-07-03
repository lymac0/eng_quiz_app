import 'package:eng_quiz_app/widgets/backbutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key});

  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  Future<bool> _isUsernameTaken(String username) async {
    DatabaseReference usernamesRef = FirebaseDatabase.instance.ref("userstats");
    DataSnapshot snapshot = await usernamesRef.child(username).get();
    return snapshot.exists;
  }

  Future<void> _validateAndSubmit() async {
    String newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      setState(() {
        _errorMessage = 'Kullanıcı adı boş bırakılamaz.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    bool isTaken = await _isUsernameTaken(newUsername);

    if (isTaken) {
      setState(() {
        _errorMessage = 'Bu kullanıcı adı zaten alınmış.';
      });
      return;
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        DatabaseReference userRef =
            FirebaseDatabase.instance.ref('users').child(uid);
        DataSnapshot userSnapshot = await userRef.get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              Map<String, dynamic>.from(userSnapshot.value as Map);
          String oldUsername = userData['username'];
          int score = userData['score'] ?? 0;

          await FirebaseDatabase.instance
              .ref('userstats')
              .child(oldUsername)
              .remove();

          await FirebaseDatabase.instance
              .ref('userstats')
              .child(newUsername)
              .set({'uid': uid, 'score': score});

          await userRef.update({'username': newUsername});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kullanıcı adı başarıyla güncellendi!'),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı adı güncellenirken hata: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kullanıcı Adını Değiştir',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Yeni kullanıcı adınızı girin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: _errorMessage,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Güncelle',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      BackButtonWidget(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
