import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'recipe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  Hive.registerAdapter(RecipeAdapter());
  await Hive.openBox<Recipe>('recipesBox');

  runApp(const MainApp());
}

class Settings {
  static String? backgroundImagePath;
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
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    recipeBox = Hive.box<Recipe>('recipesBox');
    recipes = recipeBox.values.toList();

    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
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

  List<Recipe> get filteredRecipes {
    List<Recipe> filtered = [...recipes];
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((recipe) =>
              recipe.title.toLowerCase().contains(searchQuery) ||
              recipe.description.toLowerCase().contains(searchQuery))
          .toList();
    }

    switch (sortBy) {
      case 'Difficulty':
        filtered.sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));
        break;
      case 'Stars':
        filtered.sort((a, b) => b.difficulty.compareTo(a.difficulty));
        break;
      case 'Time':
        filtered.sort(
            (a, b) => a.preparationMinutes.compareTo(b.preparationMinutes));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final displayRecipes = filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Gallery"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (Settings.backgroundImagePath != null)
            Image.file(
              File(Settings.backgroundImagePath!),
              fit: BoxFit.cover,
            ),
          // ignore: deprecated_member_use
          Container(color: Colors.black.withOpacity(0.3)),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text("Sort by: "),
                    DropdownButton<String>(
                      value: sortBy,
                      items: ['None', 'Difficulty', 'Stars', 'Time']
                          .map((value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = displayRecipes[index];
                    return GestureDetector(
                      onTap: () => openDetailPage(recipe),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: recipe.imagePath.startsWith('assets')
                                        ? Image.asset(recipe.imagePath,
                                            width: 160,
                                            height: 100,
                                            fit: BoxFit.cover)
                                        : Image.file(File(recipe.imagePath),
                                            width: 160,
                                            height: 100,
                                            fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          final idx = recipes.indexOf(recipe);
                                          recipeBox.deleteAt(idx);
                                          recipes.removeAt(idx);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 16, color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(recipe.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text("Time: ${recipe.time}'",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              Text('Difficulty: ${recipe.difficultyLevel}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return GestureDetector(
                                    onTap: () => updateDifficulty(
                                        recipes.indexOf(recipe), starIndex + 1),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
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
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddRecipePage,
        mini: true,
        child: const Icon(Icons.add),
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
              "Time: ${recipe.time}'",
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

  String _selectedDifficulty = 'Easy';

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
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

    if (_imageFile != null &&
        title.isNotEmpty &&
        time.isNotEmpty &&
        description.isNotEmpty) {
      final newRecipe = Recipe(
        imagePath: _imageFile!.path,
        title: title,
        time: time,
        description: description,
        difficultyLevel: _selectedDifficulty,
        difficulty: 0,
      );
      widget.onAdd(newRecipe);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Recipe")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                    ? Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_a_photo, size: 40),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, width: 120, height: 120),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Time (minutes)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty Level',
                border: OutlineInputBorder(),
              ),
              items: ['Easy', 'Medium', 'Hard']
                  .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.save),
                label: const Text('Save Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedBackground;

  Future<void> _pickBackgroundImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _selectedBackground = file;
        Settings.backgroundImagePath = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MainApp.themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDark,
              onChanged: (value) {
                MainApp.themeNotifier.value =
                    value ? ThemeMode.dark : ThemeMode.light;
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Select Background Image"),
              onTap: _pickBackgroundImage,
              subtitle: Settings.backgroundImagePath != null
                  ? const Text("Image selected")
                  : const Text("No image selected"),
            ),
            if (_selectedBackground != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Image.file(_selectedBackground!, height: 100),
              ),
          ],
        ),
      ),
    );
  }
}
