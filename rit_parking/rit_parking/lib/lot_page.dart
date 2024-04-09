import 'package:flutter/material.dart';

import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

import 'package:rit_parking/user_info_page.dart';

class LotPage extends StatefulWidget {
  final String lotId;

  const LotPage({super.key, required this.lotId});

  @override
  _LotPageState createState() => _LotPageState();
}

class _LotPageState extends State<LotPage> {
  List<String> _nearestBuildings = [];

  @override
  void initState() {
    super.initState();
    _loadNearestBuildings();
  }

  Future<void> _loadNearestBuildings() async {
    final csvData = await rootBundle.loadString('assets/${widget.lotId}_buildings.csv');
    setState(() {
      _nearestBuildings = csvData.split('\n');
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserInfoPage()),
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
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
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
                onPressed: () {
                  // TODO: Implement favorite functionality
                },
                icon: const Icon(Icons.favorite_border),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/lot_${widget.lotId.toLowerCase()}.jpg',
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onReservePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
                          ),
                          child: const Text(
                            'Reserve',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
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
  );
}
}