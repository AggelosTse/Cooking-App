import 'package:hive/hive.dart';

part 'recipe.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String imagePath;

  @HiveField(1)
  String title;

  @HiveField(2)
  String time;

  @HiveField(3)
  String description;

  @HiveField(4)
  int difficulty;

  @HiveField(5)
  String difficultyLevel;

  Recipe({
    required this.imagePath,
    required this.title,
    required this.time,
    required this.description,
    this.difficulty = 0,
    this.difficultyLevel = 'Medium',
  });

  int get preparationMinutes {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(time);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
}
