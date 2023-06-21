import 'dart:developer';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shortenit/main.dart';
import 'package:shortenit/models/database_model.dart';

class RecognizePage extends StatefulWidget {
  final String? path;
  const RecognizePage({Key? key, this.path}) : super(key: key);

  @override
  State<RecognizePage> createState() => _RecognizePageState();
}

class _RecognizePageState extends State<RecognizePage> {
  bool _isBusy = false;
  String recognizedText = '';
  double sliderValue = 0.0;
  String summarizedText = '';
  bool isLoading = false;
  int totalTextSize = 0;

  void showSummarySavedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Summary Saved!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final InputImage inputImage = InputImage.fromFilePath(widget.path!);
    processImage(inputImage);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight / 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => const MyApp(),
              ),
            );
          },
        ),
      ),
      body: _isBusy == true
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: cardHeight),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SingleChildScrollView(
                                  child: Text(
                                    recognizedText,
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: 100.0,
                          divisions: 4,
                          label: "${sliderValue.round()}%",
                          onChanged: (value) {
                            setState(() {
                              if (value == 0) {
                                sliderValue = 25;
                              } else {
                                sliderValue = value;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            summarizeText(recognizedText);
                          },
                          child: const Text('Summarize'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (summarizedText.isNotEmpty)
                  Card(
                    color: Theme.of(context).colorScheme.onPrimary,
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        summarizedText,
                        style: TextStyle(fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ),
                if (summarizedText.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                final box =
                                    Hive.box<SummaryQuestion>('summary_question_box');
                                final summaryQuestion = SummaryQuestion()
                                  ..summary = summarizedText
                                  ..question = 'Default Question';
                                await box.add(summaryQuestion);
                                showSummarySavedSnackbar();
                              },
                              child: const Text('Save Summary'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void processImage(InputImage image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    setState(() {
      _isBusy = true;
    });

    final RecognizedText recognizedTextResult =
        await textRecognizer.processImage(image);

    setState(() {
      recognizedText = recognizedTextResult.text;
      totalTextSize =
          recognizedText.split(' ').length; // Calculate total word count
      _isBusy = false;
    });
  }

  void summarizeText(String text) async {
    setState(() {
      isLoading = true;
      summarizedText = '';
    });

    final double percentage = sliderValue / 100.0;
    final int summarySize = (totalTextSize * percentage).round();

    final url = Uri.parse(
        'https://b251-2409-4073-4d9d-26f5-462-e5bc-484f-4a0.ngrok-free.app/summarize');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'text': text, 'summary_size': summarySize});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          summarizedText = jsonResponse['summary'];
          isLoading = false;
        });
      } else {
        log('API request failed with status code ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error occurred during API request: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
}
