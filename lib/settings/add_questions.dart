import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddQuestions extends StatefulWidget {
  const AddQuestions({super.key});

  @override
  State<AddQuestions> createState() => _AddQuestionsState();
}

class _AddQuestionsState extends State<AddQuestions> {
  String? selectedDif;
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('questions');
  final TextEditingController _soruController = TextEditingController();
  final TextEditingController _siklarController = TextEditingController();
  final TextEditingController _dogruCevapController = TextEditingController();

  Future<void> _addSoru(String selectedDif) async {
    if (_soruController.text.isNotEmpty &&
        _siklarController.text.isNotEmpty &&
        _dogruCevapController.text.isNotEmpty) {
      List<String> siklar = _siklarController.text.split(',');
      if (siklar.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az iki şık girin!')),
        );
        return;
      }

      final DataSnapshot snapshot = await _database.child(selectedDif).get();
      final int questionCount = snapshot.children.length;

      final String questionKey = 'question${questionCount + 1}';

      String soru = convertNewLine(_soruController.text);

      // Soru verilerini Firebase Realtime Database'e ekle
      await _database.child(selectedDif).child(questionKey).set({
        'question': soru,
        'options': siklar,
        'answer': _dogruCevapController.text,
      });

      // Girdi alanlarını temizle
      _soruController.clear();
      _siklarController.clear();
      _dogruCevapController.clear();

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soru başarıyla eklendi!')),
      );
    }
  }

  String convertNewLine(String content) {
    print("Converting");
    return content.replaceAll(r'\n', '\n');
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  hint: const Text('Seçenekleri Seçin'),
                  value: selectedDif,
                  items: <String>['easy', 'medium', 'hard'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDif = newValue!;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _soruController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Soru'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _siklarController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Şıklar'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _dogruCevapController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Cevap'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDif != null) {
                      _addSoru(selectedDif!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Lütfen bir zorluk seviyesi seçin!')),
                      );
                    }
                  },
                  child: const Text('Soruyu Ekle'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
