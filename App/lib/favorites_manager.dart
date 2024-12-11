import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FavoritesManager {
  // Define the filename for storing the favorite parking lots
  static const String _favoritesFilename = 'favorites.csv';

  // Get the local path for storing the favorites file
  Future<String> get _localPath async {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    // Return the path of the directory
    return directory.path;
  }

  // Get the File object for the favorites file
  Future<File> get _favoritesFile async {
    // Get the local path
    final path = await _localPath;
    // Return the File object with the favorites filename appended to the path
    return File('$path/$_favoritesFilename');
  }

  // Read the favorite parking lots from the favorites file
  Future<List<String>> readFavorites() async {
    try {
      // Get the favorites file
      final file = await _favoritesFile;
      // Read the contents of the file as a string
      final contents = await file.readAsString();
      // Split the contents by ',' and filter out empty strings
      return contents.split(',').where((favorite) => favorite.isNotEmpty).toList();
    } catch (e) {
      // If an error occurs (e.g., file not found), return an empty list
      return [];
    }
  }

  // Add a parking lot to the favorites
  Future<void> addFavorite(String lotId) async {
    // Get the favorites file
    final file = await _favoritesFile;
    // Read the current favorite parking lots
    final favorites = await readFavorites();
    // Check if the parking lot is not already in the favorites
    if (!favorites.contains(lotId)) {
      // Add the parking lot to the favorites
      favorites.add(lotId);
      // Write the updated favorites back to the file
      await file.writeAsString(favorites.join(','));
    }
  }

  // Remove a parking lot from the favorites
  Future<void> removeFavorite(String lotId) async {
    // Get the favorites file
    final file = await _favoritesFile;
    // Read the current favorite parking lots
    final favorites = await readFavorites();
    // Remove the parking lot from the favorites
    favorites.remove(lotId);
    // Write the updated favorites back to the file
    await file.writeAsString(favorites.join(','));
  }
}