import 'package:eng_quiz_app/widgets/backbutton.dart';
import 'package:eng_quiz_app/settings/account_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChangeAvatar extends StatefulWidget {
  const ChangeAvatar({super.key});

  @override
  ChangeAvatarState createState() => ChangeAvatarState();
}

class ChangeAvatarState extends State<ChangeAvatar> {
  String? selectedAvatar;
  String? currentAvatar;

  @override
  void initState() {
    super.initState();
    _fetchCurrentAvatar();
  }

  Future<void> _fetchCurrentAvatar() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final snapshot = await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(currentUser.uid)
            .get();

        if (snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            currentAvatar = data['avatar'] ?? 'assets/avatars/default.png';
            selectedAvatar = currentAvatar;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _updateAvatar(BuildContext context) async {
    if (selectedAvatar != null) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) return;

        final String uid = currentUser.uid;

        await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(uid)
            .update({'avatar': selectedAvatar});

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar başarıyla güncellendi!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avatar güncellenirken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> avatarPaths = [
      'assets/avatars/default.png',
      'assets/avatars/bird.png',
      'assets/avatars/bunny.png',
      'assets/avatars/frog.png',
      'assets/avatars/lion.png',
      'assets/avatars/monkey.png',
      'assets/avatars/owl.png',
      'assets/avatars/panda.png',
      'assets/avatars/rhino.png',
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: avatarPaths.length,
              itemBuilder: (context, index) {
                final avatar = avatarPaths[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatar = avatar;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(avatar),
                        radius: 40,
                      ),
                      if (selectedAvatar == avatar)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
            child: ElevatedButton(
              onPressed:
                  selectedAvatar == null ? null : () => _updateAvatar(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Avatar Güncelle',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          BackButtonWidget(onPressed: () async {
            Navigator.pop(context);
            await Future.delayed(const Duration(milliseconds: 200));
            showDialog(
              context: context,
              builder: (context) {
                return const AccountSettings();
              },
            );
          }),
        ],
      ),
    );
  }
}
