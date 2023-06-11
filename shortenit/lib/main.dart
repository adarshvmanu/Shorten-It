import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortenit/screens/recognize.dart';
import 'package:shortenit/utils/image_cropper.dart';
import 'package:shortenit/utils/image_picker_class.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shorten-it ',
      theme: ThemeData(
        colorSchemeSeed: Colors.purple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.purple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(title: ' Shorten-It '),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        toolbarHeight: 116,
        elevation: 2,
      ),
      body: Column(
        children: [],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            builder: (context) {
              return SizedBox(
                height: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Perform action for Button 1
                        // Add your desired logic here
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.subject,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Text',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        pickImage(source: ImageSource.camera).then((value) {
                          if (value != '') {
                            imageCropperView(value, context).then((value) {
                              if (value != '') {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) =>
                                          RecognizePage(path: value),
                                    ));
                              }
                            });
                          }
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Camera',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        pickImage(source: ImageSource.gallery).then((value) {
                          if (value != '') {
                            imageCropperView(value, context).then((value) {
                              if (value != '') {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) =>
                                          RecognizePage(path: value),
                                    ));
                              }
                            });
                          }
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Upload',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        label: const Text('Summarize'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
