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
  final String description;
  int difficulty;

  Recipe({
    required this.imagePath,
    required this.title,
    required this.time,
    required this.description,
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
      description:
          'Spaghetti alla Carbonara is a traditional Roman pasta dish known for its creamy texture without the use of cream. Made with eggs, Pecorino Romano cheese, guanciale (cured pork cheek), and black pepper, its flavor is rich, savory, and umami-forward. The dish showcases the emulsifying power of egg and cheese when combined with hot pasta water. High in protein and fat, it’s considered indulgent and best served fresh. Often enjoyed as a main course in Italy, it reflects minimalistic yet powerful Italian cooking principles.',
    ),
    Recipe(
      imagePath: 'assets/pancakes.jpg',
      title: 'Pancakes',
      time: '15 min',
      difficulty: 2,
      description:
          'Pancakes are a classic North American breakfast food made from a batter of flour, eggs, milk, and a leavening agent like baking powder. The result is a soft, fluffy interior with a slightly crisp edge when pan-fried. Their neutral flavor makes them ideal for sweet toppings like maple syrup, fruit, or chocolate. Pancakes are carbohydrate-rich and offer quick energy. Versatile and customizable, they represent comfort food culture and are often adapted into savory forms in global cuisines.',
    ),
    Recipe(
      imagePath: 'assets/steak.jpg',
      title: 'Steak',
      time: '30 min',
      difficulty: 4,
      description:
          'Steak refers to a thick cut of beef, typically from prime sections like the rib, loin, or sirloin. When grilled or pan-seared properly, it develops a Maillard-crusted exterior while retaining a juicy, tender center. The flavor is intensely beefy, slightly metallic due to iron content, and varies with fat marbling. A good steak balances tenderness, juiciness, and depth of flavor. It is protein-rich, iron-dense, and often served with sauces, vegetables, or starches to complement its richness.',
    ),
  ];

  void updateDifficulty(int index, int newRating) {
    setState(() {
      recipes[index].difficulty = newRating;
    });
  }

  void openDetailPage(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recipe Gallery")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => openDetailPage(recipe),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          recipe.imagePath,
                          width: 180,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
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
                              size: 20,
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

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              recipe.imagePath,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              recipe.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${recipe.time}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              recipe.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
