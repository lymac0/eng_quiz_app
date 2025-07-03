import 'package:eng_quiz_app/auth/forgot_password.dart';
import 'package:eng_quiz_app/screens/home_page.dart';
import 'package:eng_quiz_app/models/users.dart';
import 'package:eng_quiz_app/auth/reg_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        final userModel = await fetchUserFromDatabase(userCredential.user!.uid);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: userModel),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş hatası: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  const SizedBox(height: 50),
                  const Image(image: AssetImage("assets/images/logo.png")),
                  const SizedBox(height: 20),
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
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: const Text("Misafir olarak giriş yap",
                              style: TextStyle(
                                color: Colors.grey,
                              ))),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPassword(),
                                ));
                          },
                          child: const Text("Şifremi unuttum",
                              style: TextStyle(
                                color: Colors.grey,
                              ))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
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
                          style: TextStyle(color: Colors.white), 'Giriş Yap'),
                    ),
                  ),
                  const SizedBox(height: 90),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RegPage()));
                            },
                            child: const Text(
                              "Hesabınız yok mu?\nKaydolun",
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
