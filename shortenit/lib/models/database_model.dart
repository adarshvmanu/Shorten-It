import 'package:hive/hive.dart';

part 'database_model.g.dart';

@HiveType(typeId: 0)
class SummaryQuestion extends HiveObject {
  @HiveField(0)
  late String summary;

  @HiveField(1)
  late String question;
}
