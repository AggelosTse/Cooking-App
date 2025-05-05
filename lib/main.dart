import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImageScroller(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Recipe {
  final String imagePath;
  final String title;
  final String time;
  int difficulty;

  Recipe({
    required this.imagePath,
    required this.title,
    required this.time,
    this.difficulty = 0,
  });
}

class ImageScroller extends StatefulWidget {
  const ImageScroller({super.key});

  @override
  State<ImageScroller> createState() => _ImageScrollerState();
}

class _ImageScrollerState extends State<ImageScroller> {
  final List<Recipe> recipes = [
    Recipe(
      imagePath: 'assets/carbonara.jpg',
      title: 'Carbonara',
      time: '20 min',
      difficulty: 3,
    ),
    Recipe(
      imagePath: 'assets/pancakes.jpg',
      title: 'Pancakes',
      time: '15 min',
      difficulty: 2,
    ),
    Recipe(
      imagePath: 'assets/steak.jpg',
      title: 'Steak',
      time: '30 min',
      difficulty: 4,
    ),
  ];

  void updateDifficulty(int index, int newRating) {
    setState(() {
      recipes[index].difficulty = newRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recipe Gallery")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: 240, // Slightly taller container
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Container(
                width: 180, // Slightly wider card
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        recipe.imagePath,
                        width: 180,
                        height: 110, // Slightly taller image
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Time: ${recipe.time}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return GestureDetector(
                          onTap: () => updateDifficulty(index, starIndex + 1),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(
                              starIndex < recipe.difficulty
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20, // Larger stars
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
