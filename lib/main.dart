import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // To handle file images
import 'package:image_picker/image_picker.dart';

import 'recipe.dart'; // Import the Recipe class

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  Hive.registerAdapter(RecipeAdapter());
  await Hive.openBox<Recipe>('recipesBox');

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

class ImageScroller extends StatefulWidget {
  const ImageScroller({super.key});

  @override
  State<ImageScroller> createState() => _ImageScrollerState();
}

class _ImageScrollerState extends State<ImageScroller> {
  late Box<Recipe> recipeBox;
  List<Recipe> recipes = [];
  String sortBy = 'None';

  @override
  void initState() {
    super.initState();
    recipeBox = Hive.box<Recipe>('recipesBox');
    recipes = recipeBox.values.toList();
  }

  void updateDifficulty(int index, int newRating) {
    setState(() {
      recipes[index].difficulty = newRating;
      recipeBox.putAt(index, recipes[index]);
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
      recipeBox.add(recipe);
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

  List<Recipe> get sortedRecipes {
    List<Recipe> sorted = [...recipes];
    switch (sortBy) {
      case 'Difficulty':
        sorted.sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));
        break;
      case 'Stars':
        sorted.sort((a, b) => b.difficulty.compareTo(a.difficulty));
        break;
      case 'Time':
        sorted.sort((a, b) => a.preparationMinutes.compareTo(b.preparationMinutes));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final displayRecipes = sortedRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Gallery"),
        actions: [
          DropdownButton<String>(
            value: sortBy,
            underline: const SizedBox(),
            items: ['None', 'Difficulty', 'Stars', 'Time']
                .map((value) => DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Sort: $value"),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                sortBy = value!;
              });
            },
          ),
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
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayRecipes.length + 1,
            itemBuilder: (context, index) {
              if (index < displayRecipes.length) {
                final recipe = displayRecipes[index];
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
                                final index = recipes.indexOf(recipe);
                                recipeBox.deleteAt(index);
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
                                child: recipe.imagePath.startsWith('assets')
                                    ? Image.asset(
                                        recipe.imagePath,
                                        width: 140,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(recipe.imagePath),
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
                            onTap: () => updateDifficulty(
                                recipes.indexOf(recipe), starIndex + 1),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline, size: 48, color: Colors.black45),
                        SizedBox(height: 8),
                        Text(
                          "Add Recipe",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
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
            recipe.imagePath.startsWith('assets')
                ? Image.asset(
                    recipe.imagePath,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(recipe.imagePath),
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
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveRecipe() {
    final String title = _titleController.text;
    final String time = _timeController.text;
    final String description = _descriptionController.text;
    if (_imageFile != null && title.isNotEmpty && time.isNotEmpty && description.isNotEmpty) {
      final newRecipe = Recipe(
        imagePath: _imageFile!.path,
        title: title,
        time: time,
        description: description,
      );
      widget.onAdd(newRecipe);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Recipe")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _imageFile == null
                  ? Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo, size: 40),
                    )
                  : Image.file(_imageFile!, width: 100, height: 100),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Recipe Title'),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveRecipe,
              child: const Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
