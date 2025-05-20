part of 'recipe.dart';

// This class allows Hive to read/write Recipe objects to local storage
class RecipeAdapter extends TypeAdapter<Recipe> {
  // This ID is unique for each adapter
  @override
  final int typeId = 0;

  // read a Recipe object from binary data
  @override
  Recipe read(BinaryReader reader) {
    // Read the number of fields stored for this object
    final numOfFields = reader.readByte();

    // Read each field from the binary stream and store in a map
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) 
        reader.readByte(): reader.read(),
    };

    // Use the fields map to construct and return a Recipe object
    return Recipe(
      imagePath: fields[0] as String,
      title: fields[1] as String,
      time: fields[2] as String,
      description: fields[3] as String,
      rating: fields[4] as int,
      difficultyLevel: fields[5] as String,
    );
  }

  // This method writes a Recipe object to binary data for storage
  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(6) 
      ..writeByte(0) 
      ..write(obj.imagePath) 
      ..writeByte(1) 
      ..write(obj.title) 
      ..writeByte(2) 
      ..write(obj.time) 
      ..writeByte(3) 
      ..write(obj.description) 
      ..writeByte(4) 
      ..write(obj.rating) 
      ..writeByte(5) 
      ..write(obj.difficultyLevel); 
  }

  // Required to ensure consistency when comparing adapter instances
  @override
  int get hashCode => typeId.hashCode;

  // Ensures that two adapters of the same typeId are considered equal
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
