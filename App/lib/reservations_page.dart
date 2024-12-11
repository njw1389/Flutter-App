import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

  // Now we take reservations.csv and put the data into a List then were able to iterate 
  // thru the list filer out expired reservations and display the reservations in a list 
  // on the ReservationsPage using the ReservationItem widget.

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  List<List<dynamic>> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations(); // Load reservations when the page is initialized
  }

  Future<void> _loadReservations() async {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/reservations.csv');

    if (await file.exists()) {
      print('reservations.csv exists');

      try {
        // Read the CSV file as a string
        final csvString = await file.readAsString();
        print('\n\nCSV data:\n$csvString\n');

        // Split the CSV string into rows and convert each row to a list
        final rows = csvString.split('\n');
        final data = rows
            .map((row) => row.trim())
            .where((row) => row.isNotEmpty)
            .map((row) => const CsvToListConverter().convert(row).first)
            .toList();

        // Update the state with the loaded reservations
        setState(() {
          _reservations = data;
        });
        print('Reservations loaded: $_reservations');
      } catch (e) {
        print('Error loading reservations: $e');
      }
    } else {
      print('reservations.csv does not exist');
    }
  }

  void _updateReservations(List<dynamic> expiredReservation) {
    // Remove the expired reservation from the list of reservations
    setState(() {
      _reservations.removeWhere((r) => r[7].toString() == expiredReservation[7].toString());
      _buildReservationList();
    });

    // Navigate to the same page to trigger a rebuild
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ReservationsPage()),
    );
  }

  List<List<dynamic>> _buildReservationList() {
    // Filter out expired reservations
    final activeReservations = _reservations.where((reservation) {
      final creationTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(reservation[7].toString()),
      );
      final estimatedParkTime = reservation[6].toString().trim().split(':');
      int estimatedHours = 0, estimatedMinutes = 0;

      if (estimatedParkTime.length == 2) {
        estimatedHours = int.tryParse(estimatedParkTime[0]) ?? 0;
        estimatedMinutes = int.tryParse(estimatedParkTime[1]) ?? 0;
      }

      final estimatedDuration = Duration(hours: estimatedHours, minutes: estimatedMinutes);
      final elapsedDuration = DateTime.now().difference(creationTime);
      final remainingDuration = estimatedDuration - elapsedDuration;

      return remainingDuration.inSeconds > 0;
    }).toList();

    // Sort reservations based on remaining time
    activeReservations.sort((a, b) {
      final creationTimeA = DateTime.fromMillisecondsSinceEpoch(
        int.parse(a[7].toString()),
      );
      final estimatedParkTimeA = a[6].toString().trim().split(':');
      int estimatedHoursA = 0, estimatedMinutesA = 0;

      if (estimatedParkTimeA.length == 2) {
        estimatedHoursA = int.tryParse(estimatedParkTimeA[0]) ?? 0;
        estimatedMinutesA = int.tryParse(estimatedParkTimeA[1]) ?? 0;
      }

      final estimatedDurationA = Duration(hours: estimatedHoursA, minutes: estimatedMinutesA);
      final elapsedDurationA = DateTime.now().difference(creationTimeA);
      final remainingDurationA = estimatedDurationA - elapsedDurationA;

      final creationTimeB = DateTime.fromMillisecondsSinceEpoch(
        int.parse(b[7].toString()),
      );
      final estimatedParkTimeB = b[6].toString().trim().split(':');
      int estimatedHoursB = 0, estimatedMinutesB = 0;

      if (estimatedParkTimeB.length == 2) {
        estimatedHoursB = int.tryParse(estimatedParkTimeB[0]) ?? 0;
        estimatedMinutesB = int.tryParse(estimatedParkTimeB[1]) ?? 0;
      }

      final estimatedDurationB = Duration(hours: estimatedHoursB, minutes: estimatedMinutesB);
      final elapsedDurationB = DateTime.now().difference(creationTimeB);
      final remainingDurationB = estimatedDurationB - elapsedDurationB;

      return remainingDurationA.compareTo(remainingDurationB);
    });

    return activeReservations;
  }

  @override
  Widget build(BuildContext context) {
    final displayedReservations = _buildReservationList();

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
                        'Reservations',
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
            child: displayedReservations.isEmpty
                ? const Center(
                    child: Text(
                      'No active reservations found.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: displayedReservations.length,
                    itemBuilder: (context, index) {
                      final reservation = displayedReservations[index];
                      return ReservationItem(
                        reservation: reservation,
                        onReservationExpired: _updateReservations,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ReservationItem extends StatefulWidget {
  final List<dynamic> reservation;
  final Function(List<dynamic>) onReservationExpired;

  const ReservationItem({
    super.key,
    required this.reservation,
    required this.onReservationExpired,
  });

  @override
  _ReservationItemState createState() => _ReservationItemState();
}

class _ReservationItemState extends State<ReservationItem> {
  late Duration _remainingDuration;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the timer when the reservation item is initialized
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the reservation item is disposed
    super.dispose();
  }

  void _startTimer() {
    // Calculate the remaining duration for the reservation
    final creationTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(widget.reservation[7].toString()),
    );
    final estimatedParkTime = widget.reservation[6].toString().trim().split(':');
    int estimatedHours = 0, estimatedMinutes = 0;

    if (estimatedParkTime.length == 2) {
      estimatedHours = int.tryParse(estimatedParkTime[0]) ?? 0;
      estimatedMinutes = int.tryParse(estimatedParkTime[1]) ?? 0;
    }

    final estimatedDuration = Duration(hours: estimatedHours, minutes: estimatedMinutes);
    final elapsedDuration = DateTime.now().difference(creationTime);
    _remainingDuration = estimatedDuration - elapsedDuration;

    // Start a periodic timer to update the remaining duration every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingDuration -= const Duration(seconds: 1);
        if (_remainingDuration.inSeconds <= 0) {
          timer.cancel();
          _remainingDuration = Duration.zero;
          widget.onReservationExpired(widget.reservation); // Notify when the reservation expires
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    // Format the duration as HH:MM:SS
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          'Reservation ${widget.reservation[8]}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Lot: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.reservation[8]),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Name: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.reservation[0]),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'License Plate: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.reservation[1]),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'State: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.reservation[2]),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Make: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.reservation[3]),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Model: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.reservation[4]),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Color: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.reservation[5]),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time Remaining: ${_formatDuration(_remainingDuration)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}