import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

  // We now save the reservation data to reservations.csv we do this on this page because we know the reservation was successful
  // This function reads the user data from user_data.csv and appends it to reservations.csv as a new reservation in the CSV 
  // format: "Name,License-Plate,Make,Model,Color,Park-Duration,Time-Since-Unix-Epoch" per line.

class ReservationConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Save the reservation data to reservations.csv
    _saveReservationToCSV();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RIT Parking',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Display a confirmation message with a checkmark icon
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Reservation Confirmed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Display a "Back to Home" button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveReservationToCSV() async {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    // Create File objects for user_data.csv and reservations.csv
    final userDataFile = File('$path/user_data.csv');
    final reservationsFile = File('$path/reservations.csv');

    // Read the user data from user_data.csv
    final userData = await userDataFile.readAsString();
    final userDataList = const CsvToListConverter().convert(userData);

    // Convert the user data list to a CSV string
    final csvData = const ListToCsvConverter().convert(userDataList);

    // Append the user data to reservations.csv
    await reservationsFile.writeAsString(
      '$csvData\n',
      mode: FileMode.append,
    );

    print('Reservation data appended to reservations.csv');
  }
}