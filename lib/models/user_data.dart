import 'package:hive/hive.dart';

part 'user_data.g.dart';

@HiveType(typeId: 0)
class UserData extends HiveObject {
  @HiveField(0)
  DateTime? birthday;

  @HiveField(1)
  int? expectedLifespan;

  @HiveField(2)
  List<ImportantDate> importantDates;

  UserData({
    this.birthday,
    this.expectedLifespan,
    this.importantDates = const [],
  });
}

@HiveType(typeId: 1)
class ImportantDate extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime date;

  ImportantDate({
    required this.title,
    required this.date,
  });
}
