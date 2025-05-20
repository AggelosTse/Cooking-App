import 'package:hive/hive.dart';

part 'recipe.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String imagePath;   // initialize user's image path

  @HiveField(1)
  String title;       // / initialize title for every recipe

  @HiveField(2)
  String time;        // initialize time for every recipe

  @HiveField(3)
  String description; // initialize description for every recipe

  @HiveField(4)
  int rating;     // initialize star rating for every recipe 

  @HiveField(5)
  String difficultyLevel; //initialize difficulty for every recipe

  Recipe({
    required this.imagePath,
    required this.title,
    required this.time,
    required this.description,
    this.rating = 0,
    this.difficultyLevel = 'Medium',
  });

  int get preparationMinutes {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(time);
    return match != null ? int.parse(match.group(1)!) : 0;    
  }
}
