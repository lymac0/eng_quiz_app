import 'package:eng_quiz_app/auth/login_page.dart';
import 'package:eng_quiz_app/settings/add_questions.dart';
import 'package:eng_quiz_app/widgets/backbutton.dart';
import 'package:eng_quiz_app/settings/account_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  bool _selection = true;

  bool checkAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.uid == "MlUScySIXEWaT0pZfWgz9MfcxJn2") {
      return true;
    }
    return false;
  }

  Future _logoutQuery(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Çıkış yapmak istediğinizden emin misiniz?",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        _logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Çıkış Yap',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    BackButtonWidget(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw 'Bağlantı zaman aşımına uğradı.',
          );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çıkış yaparken bir hata oluştu: $e')),
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
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Ayarlar",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                ListTile(
                    leading: const Icon(Icons.manage_accounts,
                        color: Colors.deepPurple),
                    title: const Text('Hesap Ayarları'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const AccountSettings();
                          });
                    }),
                /*ListTile(
                  leading:
                      const Icon(Icons.bar_chart, color: Colors.deepPurple),
                  title: const Text('İstatistik'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),*/
                if (checkAdmin())
                  ListTile(
                    leading:
                        const Icon(Icons.add_box, color: Colors.deepPurple),
                    title: const Text('Soru ekle'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const AddQuestions();
                          });
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.deepPurple),
                  title: const Text('Çıkış Yap'),
                  onTap: () {
                    _logoutQuery(context);
                  },
                ),
                SwitchListTile(
                  value: _selection,
                  onChanged: (bool newValue) {
                    setState(() {
                      _selection = newValue;
                    });
                  },
                  title: const Text('Sesler'),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
          Positioned(
            bottom: -20,
            right: 16,
            left: 16,
            child: BackButtonWidget(onPressed: () {
              Navigator.pop(context);
            }),
          ),
        ],
      ),
    );
  }
}
