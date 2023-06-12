import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortenit/screens/recognize.dart';
import 'package:shortenit/utils/image_cropper.dart';
import 'package:shortenit/utils/image_picker_class.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shortenit/models/database_model.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(SummaryQuestionAdapter());
  await Hive.openBox<SummaryQuestion>('summary_question_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Shorten-it ',
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: const HomePage(title: ' Shorten-It '),
        debugShowCheckedModeBanner: false,
      );
    });
  }

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _MyHomePageState();
}

class HiveBoxListView extends StatefulWidget {
  const HiveBoxListView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HiveBoxListViewState createState() => _HiveBoxListViewState();
}

class _HiveBoxListViewState extends State<HiveBoxListView> {
  late Box<SummaryQuestion> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<SummaryQuestion>('summary_question_box');
  }

  void deleteItem(int index) {
    box.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: box.length,
      itemBuilder: (context, index) {
        final reversedIndex = box.length - 1 - index;
        final summaryQuestion = box.getAt(reversedIndex) as SummaryQuestion;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summaryQuestion.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(summaryQuestion.summary),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteItem(reversedIndex),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
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
      body: Container(
          padding: const EdgeInsets.all(8.0), child: const HiveBoxListView()),
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
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: const Icon(
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
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: const Icon(
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
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: const Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
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
