import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rit_parking/favorites_manager.dart';
import 'package:rit_parking/reservations_page.dart';
import 'package:rit_parking/favorites_page.dart';
import 'package:rit_parking/user_info_page.dart';

class LotPage extends StatefulWidget {
  final String lotId;
  final Function(String)? onFavoriteChanged;

  const LotPage({
    super.key,
    required this.lotId,
    this.onFavoriteChanged,
  });

  @override
  _LotPageState createState() => _LotPageState();
}

class _LotPageState extends State<LotPage> {
  List<String> _nearestBuildings = [];
  bool _isFavorite = false;
  final FavoritesManager _favoritesManager = FavoritesManager();
  bool isDrawerOpen = false;
  Timer? _favoriteTimer;

  @override
  void initState() {
    super.initState();
    _loadNearestBuildings(); // Load the nearest buildings from the CSV file
    _checkFavorite(); // Check if the lot is marked as a favorite
    _startFavoriteTimer(); // Start a timer to periodically check the favorite status
  }

  @override
  void dispose() {
    _favoriteTimer?.cancel(); // Cancel the favorite timer when the widget is disposed
    super.dispose();
  }

  void _startFavoriteTimer() {
    // Start a timer that checks the favorite status every 2 seconds
    _favoriteTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkFavorite();
    });
  }

  Future<void> _checkFavorite() async {
    // Read the favorites from the FavoritesManager
    final favorites = await _favoritesManager.readFavorites();
    // Check if the current lot is in the favorites list
    _isFavorite = favorites.contains(widget.lotId);
    setState(() {}); // Trigger a rebuild of the widget
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      // Remove the lot from favorites
      await _favoritesManager.removeFavorite(widget.lotId);
      if (widget.onFavoriteChanged != null) {
        widget.onFavoriteChanged!(widget.lotId); // Call the callback
      }
    } else {
      // Add the lot to favorites
      await _favoritesManager.addFavorite(widget.lotId);
    }
    setState(() {
      _isFavorite = !_isFavorite; // Toggle the favorite status
    });
  }

  Future<void> _loadNearestBuildings() async {
    // Load the CSV file containing the nearest buildings for the current lot
    final csvData = await rootBundle.loadString('assets/${widget.lotId.replaceAll(' ', '-')}_buildings.csv');
    setState(() {
      _nearestBuildings = csvData.split('\n'); // Split the CSV data into a list of buildings
    });
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

  void _onReservePressed() {
    // Navigate to the UserInfoPage when the Reserve button is pressed
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserInfoPage(lotId: widget.lotId)),
    );
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
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, // Removes the default back button
        actions: [
          IconButton(
            icon: isDrawerOpen ? const Icon(Icons.close) : const Icon(Icons.menu),
            onPressed: () {
              setState(() {
                isDrawerOpen = !isDrawerOpen; // Toggle the drawer state
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: isDrawerOpen ? 250 : 0,
            top: 0,
            bottom: 0,
            right: isDrawerOpen ? -250 : 0,
            child: AbsorbPointer(
              absorbing: isDrawerOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            Text(
                              '${widget.lotId} Lot',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.black,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ],
                        ),
                      ),
                    ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/${widget.lotId.replaceAll(' ', '-')}.jpg',
                            width: double.infinity,
                            height: 400,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Availability',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('${_getRandomAvailability()} Spots'),
                                const SizedBox(height: 24),
                                const Text(
                                  'Nearest Buildings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _nearestBuildings
                                      .map((building) => Text('- $building'))
                                      .toList(),
                                ),
                                const SizedBox(height: 24),
                                Center ( 
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _onReservePressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: const Text(
                                        'Reserve',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Side menu
          Positioned(
            left: isDrawerOpen ? 0 : -250,
            top: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 250,
              color: isDrawerOpen
                  ? const Color.fromRGBO(247, 105, 2, 1)
                  : Colors.transparent,
              child: ListView(
                children: [
                  InkWell(
                    onTap: () {
                      // Navigate to the reservations page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReservationsPage()),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 2.0),
                          bottom: BorderSide(color: Colors.white, width: 2.0),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Reservations',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigate to the favorites page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesPage()),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 2.0),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Favorites',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}