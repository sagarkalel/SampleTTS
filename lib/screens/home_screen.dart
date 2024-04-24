import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as dev;

import 'package:sample_text_to_speech/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _editingController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Map _currentVoice = {};
  List<Map> _voices = [];
  int? _currentWordStart;
  int? _currentWordEnd;
  double _voicePitch = 1.0;

  @override
  void initState() {
    super.initState();
    getVoice();
  }

  void getVoice() {
    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        _currentWordStart = start;
        _currentWordEnd = end;
      });
    });
    _flutterTts.setCompletionHandler(() {
      stopTts();
    });

    _flutterTts.getVoices.then((data) {
      try {
        _voices = List<Map>.from(data);
        dev.log(_voices.toString());
        _currentVoice = _voices.first;
        setVoice(_currentVoice);
        setState(() {});
      } catch (e) {
        dev.log("error while initializing flutter tts: $e");
      }
    });
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({'name': voice['name'], 'locale': voice['locale']});
  }

  void stopTts() {
    _flutterTts.stop();
    _currentWordEnd = _currentWordStart = null;
    setState(() {});
  }

  void startSpeak() {
    _flutterTts.setPitch(_voicePitch);
    _flutterTts.speak(Constants.ttsInput);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sample TTS")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildUi(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentWordStart != null)
            AvatarGlow(
              child: FloatingActionButton(
                onPressed: stopTts,
                backgroundColor: Colors.grey,
                child: const Icon(Icons.stop_circle_outlined),
              ),
            ),
          if (_currentWordStart != null)
            const SizedBox(height: 30)
          else
            FloatingActionButton(
              onPressed: startSpeak,
              child: const Icon(Icons.speaker_phone),
            ),
          if (_currentWordStart == null) const SizedBox(height: 30)
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Widget _buildUi() {
    return SafeArea(
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _speakerSelector(),
              IconButton(
                  onPressed: searchByLangCode, icon: const Icon(Icons.search))
            ],
          ),
          const SizedBox(height: 50),
          RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                  style: const TextStyle(fontWeight: FontWeight.w400),
                  children: [
                    // TextSpan(
                    //     text: Constants.ttsInput.substring(0, _currentWordStart)),
                    // if (_currentWordStart != null)
                    //   TextSpan(
                    //     text: Constants.ttsInput
                    //         .substring(_currentWordStart!, _currentWordEnd),
                    //     style:
                    //         const TextStyle(backgroundColor: Colors.purpleAccent),
                    //   ),
                    // if (_currentWordEnd != null)
                    //   TextSpan(
                    //       text: Constants.ttsInput.substring(_currentWordEnd!)),
                    if (_currentWordEnd == null && _currentWordStart == null)
                      TextSpan(
                        text: Constants.ttsInput,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70),
                      ),
                    if (_currentWordEnd != null)
                      TextSpan(
                        text: Constants.ttsInput.substring(0, _currentWordEnd),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    if (_currentWordEnd != null)
                      TextSpan(
                        text: Constants.ttsInput.substring(_currentWordEnd!),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70),
                      ),
                  ])),
          const SizedBox(height: 50),
          IconButton(
              onPressed: changeReadingText,
              icon: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_note),
                  Text("Change reading text"),
                ],
              )),
          IconButton(
              onPressed: changeVoicePitch,
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_voice_outlined),
                  Text(
                      "Change voice pitch (current is ${_voicePitch.toStringAsFixed(1)})"),
                ],
              )),
          // const Spacer(),
          const Text(
            "Note: From dropdown you can change voice, each dropdown showing which all are voice included in that.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 50),
        ],
      ),
    ));
  }

  Widget _speakerSelector() {
    return DropdownButton(
      value: _currentVoice,
      items: _voices
          .map((e) => DropdownMenuItem(value: e, child: Text(e['name'])))
          .toList(),
      onChanged: (value) {
        _currentVoice = value!;
        setVoice(_currentVoice);
        stopTts();
      },
    );
  }

  void changeReadingText() {
    _editingController.clear();
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
            "Write or paste reading text here and click on Save button!",
            textAlign: TextAlign.start),
        content: Material(
          child: TextField(
            controller: _editingController,
            maxLines: 5,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Reading text here...'),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                if (_editingController.text.length >= 3) {
                  Constants.ttsInput = _editingController.text;
                  setState(() {});
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please try to add more text")));
                }
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  void changeVoicePitch() {
    double oldPitch = _voicePitch;
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Change voice pitch value here click on Save button!",
            textAlign: TextAlign.start),
        content: Material(
          child: StatefulBuilder(
            builder: (context, changeState) {
              return Slider(
                value: oldPitch,
                min: 0.5,
                max: 1.5,
                divisions: 10,
                onChanged: (value) {
                  oldPitch = value;
                  changeState(() {});
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                _voicePitch = oldPitch;
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  void searchByLangCode() {
    List<Map> oldVoices = _voices;
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Set voice from tapping on any of below!",
            textAlign: TextAlign.start),
        content: Material(
          child: StatefulBuilder(
            builder: (context, changeState) {
              if (_searchController.text.isNotEmpty) {
                oldVoices = oldVoices.where((element) {
                  if (element.containsKey('name')) {
                    return element['name'].contains(_searchController.text) ||
                        element['locale'].contains(_searchController.text);
                  } else {
                    return false;
                  }
                }).toList();
              }
              return Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          oldVoices = _voices;
                        }
                        changeState(() {});
                      },
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'Search by lang code here...',
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          suffixIcon: IconButton(
                              onPressed: () {
                                _searchController.clear();
                                oldVoices = _voices;
                                changeState(() {});
                              },
                              icon: const Icon(Icons.clear))),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      itemCount: oldVoices.length,
                      itemBuilder: (context, index) {
                        var item = oldVoices[index];
                        return ListTile(
                          title: Text(item['name']),
                          onTap: () {
                            _currentVoice = item;
                            setVoice(item);
                            stopTts();
                            setState(() {});
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"))
        ],
      ),
    );
  }
}
