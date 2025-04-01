import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: FlashcardScreen());
  }
}

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Map<String, dynamic>> _consonants = [];
  Map<String, dynamic>? _currentConsonant;
  List<String> _soundOptions = [];
  List<String> _classOptions = ["Mid", "Low", "High"];
  String? _selectedSound;
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    _loadConsonants();
  }

  Future<void> _loadConsonants() async {
    String jsonString = await rootBundle.loadString('assets/consonants.json');
    List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      _consonants = List<Map<String, dynamic>>.from(jsonResponse);
      _generateNewQuestion();
    });
  }

  void _generateNewQuestion() {
    if (_consonants.isNotEmpty) {
      final random = Random();
      _currentConsonant = _consonants[random.nextInt(_consonants.length)];

      Set<String> soundChoices = {_currentConsonant!["sound"]};
      while (soundChoices.length < 3) {
        soundChoices.add(
          _consonants[random.nextInt(_consonants.length)]["sound"],
        );
      }

      setState(() {
        _soundOptions = soundChoices.toList()..shuffle();
        _selectedSound = null;
        _selectedClass = null;
      });
    }
  }

  void _validateAnswer() {
    if (_selectedSound == null || _selectedClass == null) return;

    bool correctSound = _selectedSound == _currentConsonant!["sound"];
    bool correctClass = _selectedClass == _currentConsonant!["class"];

    String message;
    if (correctSound && correctClass) {
      message = "Well done! You got both right!";
    } else if (correctSound) {
      message = "Correct sound but wrong class.";
    } else if (correctClass) {
      message = "Correct class but wrong sound.";
    } else {
      message = "Both answers are incorrect. Try again!";
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              correctSound && correctClass ? "Correct!" : "Incorrect",
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _generateNewQuestion();
                },
                child: const Text("Continue"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn Thai Consonants")),
      body:
          _currentConsonant == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/consonants/${_currentConsonant!["id"]}/image.png',
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    Text("What is the class of this consonant?"),
                    const SizedBox(height: 10),
                    ..._classOptions.map(
                      (c) => RadioListTile<String>(
                        title: Text(c),
                        value: c,
                        groupValue: _selectedClass,
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("What is the sound of this consonant?"),
                    const SizedBox(height: 10),
                    ..._soundOptions.map(
                      (sound) => RadioListTile<String>(
                        title: Text(sound),
                        value: sound,
                        groupValue: _selectedSound,
                        onChanged: (value) {
                          setState(() {
                            _selectedSound = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _validateAnswer,
                      child: const Text("Validate"),
                    ),
                  ],
                ),
              ),
    );
  }
}
