import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
      appBar: AppBar(title: const Text("Recognized Page")),
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
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Container(
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
                              sliderValue = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            // Perform summarize action
                          },
                          child: const Text('Summarize'),
                        ),
                      ),
                    ],
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

    log(image.filePath!);
    final RecognizedText recognizedTextResult =
        await textRecognizer.processImage(image);
    setState(() {
      recognizedText = recognizedTextResult.text;
      _isBusy = false;
    });
  }
}
