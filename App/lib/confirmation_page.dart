import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:rit_parking/Reservation_Confirmation.dart';
import 'package:rit_parking/reservations_page.dart';
import 'package:rit_parking/favorites_page.dart';

  // For this page we load and display the data from the user_data.csv file, then
  // in _navigateToReservationConfirmationPage we update the time since the Unix 
  // Epoch which is 1970-01-01T00:00:00Z (UTC) we do this because every second we 
  // sit on this page thats a second subtracted from the reservation since we take 
  // the time since epoch and duration to calculate the timer. We then navigate to
  // the ReservationConfirmationPage and display the confirmation message.

class ConfirmationPage extends StatefulWidget {
  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  bool isDrawerOpen = false;

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
        automaticallyImplyLeading: false,
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
              child: FutureBuilder<List<List<dynamic>>>(
                future: _loadDataFromCSV(), // Load data from CSV file
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!; // Get the loaded data
                    return Column(
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
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'Confirm Information',
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
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Center(
                                  child: Text(
                                    'Please confirm your information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Display the loaded data in a formatted manner
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Text(
                                        'Lot:',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data[0][8],
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 170,
                                      child: Text(
                                        'First & Last Name:',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data[0][0],
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Text(
                                        'License Plate:',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data[0][1],
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 170,
                                      child: Text(
                                        'State Registered:',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data[0][2],
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Text(
                                        'Make:',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data[0][3],
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Text(
                                        'Model:',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data[0][4],
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Text(
                                        'Color:',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data[0][5],
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Estimated Park Time:',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data[0][6],
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _navigateToReservationConfirmationPage(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Submit',
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
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(247, 105, 2, 1)),
                    ),
                  );
                },
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
                        MaterialPageRoute(builder: (context) => const ReservationsPage()),
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
                        MaterialPageRoute(builder: (context) => const FavoritesPage()),
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

  Future<List<List<dynamic>>> _loadDataFromCSV() async {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/user_data.csv');
    // Read the CSV file as a string
    final csvString = await file.readAsString();
    // Convert the CSV string to a list of lists
    return const CsvToListConverter().convert(csvString);
  }

  void _navigateToReservationConfirmationPage(BuildContext context) async {
    // Read the data from user_data.csv
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/user_data.csv');
    final csvString = await file.readAsString();
    final data = const CsvToListConverter().convert(csvString);

    // Update the millisecondsSinceEpoch value with the current timestamp
    data[0][7] = DateTime.now().millisecondsSinceEpoch.toString();

    // Save the updated data back to user_data.csv
    final updatedCsvString = const ListToCsvConverter().convert(data);
    await file.writeAsString(updatedCsvString);

    // Navigate to the Reservation_Confirmation page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ReservationConfirmationPage()),
    );
  }
}