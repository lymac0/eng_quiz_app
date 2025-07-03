import 'package:eng_quiz_app/settings/delete_account.dart';
import 'package:eng_quiz_app/widgets/backbutton.dart';
import 'package:eng_quiz_app/settings/change_avatar.dart';
import 'package:eng_quiz_app/settings/change_username.dart';
import 'package:eng_quiz_app/settings/settings_menu.dart';
import 'package:flutter/material.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key});

  Future _deleteAccount(BuildContext context) {
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
                    "Hesabınızı silmek istediğinizden emin misiniz?",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const DeleteAccount();
                          },
                        );
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
                        'Sil',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    BackButtonWidget(onPressed: () {
                      Navigator.pop(context);
                    }),
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
                ListTile(
                  leading: const Icon(Icons.account_circle,
                      color: Colors.deepPurple),
                  title: const Text('Avatarı Değiştir'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const ChangeAvatar();
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.deepPurple),
                  title: const Text('Kullanıcı Adı Değiştir'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const ChangeUsername();
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.deepPurple),
                  title: const Text('Hesabı Sil'),
                  onTap: () {
                    _deleteAccount(context);
                  },
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
              showDialog(
                context: context,
                builder: (context) {
                  return const SettingsMenu();
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
