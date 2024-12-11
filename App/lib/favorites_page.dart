import 'package:flutter/material.dart';
import 'dart:math';
import 'package:rit_parking/favorites_manager.dart';
import 'package:rit_parking/lot_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesManager _favoritesManager = FavoritesManager();
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites(); // Load the user's favorite parking lots when the page is initialized
  }

  Future<void> _loadFavorites() async {
    _favorites = await _favoritesManager.readFavorites(); // Read the user's favorite parking lots from the FavoritesManager
    setState(() {}); // Trigger a rebuild of the widget to display the loaded favorites
  }

  void _removeFavorite(String lotId) {
    setState(() {
      _favorites.remove(lotId); // Remove the specified parking lot from the user's favorites
    });
  }

  Future<int> _getAvailableSpots(String lotId) async {
    // Simulating an asynchronous call to retrieve the available spots for a parking lot
    await Future.delayed(const Duration(seconds: 1));
    return _getRandomAvailability(); // Return a random number of available spots
  }

  int _getRandomAvailability() {
    final random = Random();
    final currentTime = DateTime.now();
    final currentDay = currentTime.weekday;

    // Define time ranges and corresponding spot ranges for weekdays
    const morningStart = 7;
    const morningEnd = 10;
    const afternoonStart = 12;
    const afternoonEnd = 14;
    const eveningStart = 17;
    const eveningEnd = 20;

    const int minSpotsMorningAfternoon = 20;
    const int maxSpotsMorningAfternoon = 50;
    const int minSpotsEvening = 10;
    const int maxSpotsEvening = 30;
    const int minSpotsInBetween = 100;
    const int maxSpotsInBetween = 150;

    // Define spot ranges for weekends
    const int minSpotsWeekend = 175;
    const int maxSpotsWeekend = 300;

    // Check if it's a weekend (Saturday or Sunday)
    if (currentDay == DateTime.saturday || currentDay == DateTime.sunday) {
      // Weekend: more spots available
      return random.nextInt(maxSpotsWeekend - minSpotsWeekend + 1) + minSpotsWeekend;
    } else {
      // Weekday: check if the current time falls within the defined ranges
      if ((currentTime.hour >= morningStart && currentTime.hour < morningEnd) ||
          (currentTime.hour >= afternoonStart && currentTime.hour < afternoonEnd)) {
        // Morning and afternoon: fewer spots
        return random.nextInt(maxSpotsMorningAfternoon - minSpotsMorningAfternoon + 1) + minSpotsMorningAfternoon;
      } else if (currentTime.hour >= eveningStart && currentTime.hour < eveningEnd) {
        // Evening: even fewer spots
        return random.nextInt(maxSpotsEvening - minSpotsEvening + 1) + minSpotsEvening;
      } else {
        // In between: more spots
        return random.nextInt(maxSpotsInBetween - minSpotsInBetween + 1) + minSpotsInBetween;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RIT Parking',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _favorites.isNotEmpty
                ? ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final lotId = _favorites[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$lotId Lot',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    FutureBuilder<int>(
                                      future: _getAvailableSpots(lotId),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Text('${snapshot.data} Spots Left');
                                        } else {
                                          return const Text('Loading...');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Stack(
                                  children: [
                                    Image.asset(
                                      'assets/${lotId.replaceAll(' ', '-')}.jpg',
                                      width: double.infinity,
                                      height: 300,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Navigate to the LotPage when the Reserve button is pressed
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LotPage(
                                                  lotId: lotId,
                                                  onFavoriteChanged: _removeFavorite,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
                                          ),
                                          child: const Text(
                                            'Reserve',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No favorites added yet.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}