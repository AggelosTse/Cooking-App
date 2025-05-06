import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          home: const ImageScroller(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class Recipe {
  final String imagePath;
  final String title;
  final String time;
  final String description;
  int difficulty;
  String difficultyLevel;

  Recipe({
    required this.imagePath,
    required this.title,
    required this.time,
    required this.description,
    this.difficulty = 0,
    this.difficultyLevel = 'Medium',
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
      difficultyLevel: 'Medium',
      description: 'Spaghetti alla Carbonara is a traditional Roman pasta dish...',
    ),
    Recipe(
      imagePath: 'assets/pancakes.jpg',
      title: 'Pancakes',
      time: '15 min',
      difficulty: 2,
      difficultyLevel: 'Easy',
      description: 'Pancakes are a classic North American breakfast food...',
    ),
    Recipe(
      imagePath: 'assets/steak.jpg',
      title: 'Steak',
      time: '30 min',
      difficulty: 4,
      difficultyLevel: 'Hard',
      description: 'Steak is a thick slice of beef typically grilled or pan-seared...',
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

  void addNewRecipe(Recipe recipe) {
    setState(() {
      recipes.add(recipe);
    });
  }

  void openAddRecipePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecipePage(onAdd: addNewRecipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Gallery"),
        actions: [
          IconButton(
            icon: Icon(
              MainApp.themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              MainApp.themeNotifier.value =
                  MainApp.themeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length + 1,
            itemBuilder: (context, index) {
              if (index < recipes.length) {
                final recipe = recipes[index];
                return Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                recipes.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.remove, color: Colors.white, size: 16),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => openDetailPage(recipe),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  recipe.imagePath,
                                  width: 140,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                      Text(
                        'Difficulty: ${recipe.difficultyLevel}',
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
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
              } else {
                return GestureDetector(
                  onTap: openAddRecipePage,
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 40, color: Colors.black54),
                    ),
                  ),
                );
              }
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
            const SizedBox(height: 8),
            Text(
              'Difficulty: ${recipe.difficultyLevel}',
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

class AddRecipePage extends StatefulWidget {
  final Function(Recipe) onAdd;

  const AddRecipePage({super.key, required this.onAdd});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String time = '';
  String description = '';
  int difficulty = 0;
  String difficultyLevel = 'Medium';

  String imagePath = 'assets/placeholder.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Recipe")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (val) => title = val ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Time (e.g. 20 min)'),
                onSaved: (val) => time = val ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                onSaved: (val) => description = val ?? '',
              ),
              const SizedBox(height: 12),
              const Text("Difficulty (user rating):"),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      difficulty = index + 1;
                    }),
                    child: Icon(
                      index < difficulty ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: difficultyLevel,
                decoration: const InputDecoration(labelText: 'Difficulty Level'),
                items: ['Easy', 'Medium', 'Hard'].map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    difficultyLevel = val ?? 'Medium';
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  widget.onAdd(
                    Recipe(
                      imagePath: imagePath,
                      title: title,
                      time: time,
                      description: description,
                      difficulty: difficulty,
                      difficultyLevel: difficultyLevel,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Add Recipe"),
              )
            ],
          ),
        ),
      ),
    );
  }
}