import 'package:eng_quiz_app/screens/home_page.dart';
import 'package:eng_quiz_app/models/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<bool> _isUsernameAvailable(String username) async {
    DatabaseReference usernamesRef = FirebaseDatabase.instance.ref("userstats");
    DataSnapshot snapshot = await usernamesRef.child(username).get();

    return !snapshot.exists;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool isAvailable = await _isUsernameAvailable(_usernamecontroller.text);

        if (!isAvailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu kullanıcı adı zaten alınmış')),
          );
          return;
        }

        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        User? user = userCredential.user;
        if (user != null) {
          await userCredential.user!
              .updateDisplayName(_usernamecontroller.text);
        }

        Users newUser = Users(
            uid: user!.uid,
            username: _usernamecontroller.text,
            email: _emailController.text,
            score: 0,
            avatar: 'assets/avatars/default.png');

        DatabaseReference userRef =
            FirebaseDatabase.instance.ref("users/${user.uid}");
        await userRef.set(newUser.toJson());

        DatabaseReference userstatsRef =
            FirebaseDatabase.instance.ref("userstats");

        await userstatsRef
            .child(_usernamecontroller.text)
            .set({'score': 0, 'uid': user.uid});

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              user: newUser,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş hatası: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernamecontroller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [
            const Color.fromARGB(255, 97, 64, 153),
            Colors.deepPurple.shade900,
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  const Image(image: AssetImage("assets/images/logo.png")),
                  const SizedBox(height: 20),
                  TextFormField(
                      controller: _usernamecontroller,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Kullanıcı Adı',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen kullanıcı adınızı girin';
                        }
                        return null;
                      }),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      hintText: 'E-posta',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen e-postanızı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      hintText: 'Şifre',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen şifrenizi girin';
                      } else if (value.length < 6) {
                        return 'Şifreniz en az 6 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(4), // Köşe yuvarlaklığı
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                            Colors.red.shade700), // Arka plan rengi
                        foregroundColor:
                            WidgetStateProperty.all(Colors.black), // Yazı rengi
                      ),
                      child: const Text(
                          style: TextStyle(color: Colors.white), 'Kayıt Ol'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
