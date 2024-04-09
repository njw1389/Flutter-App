import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:io';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController _firstLastNameController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _stateRegisteredController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  int _hours = 0;
  int _minutes = 15;

  @override
  void initState() {
    super.initState();
    _clearCSVFile();
  }

  void _clearCSVFile() async {
    final file = File('user_data.csv');
    await file.writeAsString('');
  }

  void _saveDataToCSV() async {
    final data = [
      [
        _firstLastNameController.text,
        _licensePlateController.text,
        _stateRegisteredController.text,
        _makeController.text,
        _modelController.text,
        _colorController.text,
        '$_hours hours $_minutes mins',
      ],
    ];

    String csvData = const ListToCsvConverter().convert(data);
    final file = File('user_data.csv');
    await file.writeAsString(csvData);
  }

  void _navigateToConfirmationPage() {
    _saveDataToCSV();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfirmationPage()),
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
        automaticallyImplyLeading: false,
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
                const Expanded(
                  child: Center(
                    child: Text(
                      'Parker Information',
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

						const SizedBox(height: 16),
						Expanded(
							child: SingleChildScrollView(
            	padding: const EdgeInsets.all(16.0),
            	child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
								
							TextField(
								controller: _firstLastNameController,
								decoration: const InputDecoration(
									labelText: 'First & Last Name',
								),
							),
							const SizedBox(height: 16),
							TextField(
								controller: _licensePlateController,
								decoration: const InputDecoration(
									labelText: 'License Plate',
								),
							),
							const SizedBox(height: 16),
							TextField(
								controller: _stateRegisteredController,
								decoration: const InputDecoration(
									labelText: 'State Registered',
								),
							),
							const SizedBox(height: 16),
							TextField(
								controller: _makeController,
								decoration: const InputDecoration(
									labelText: 'Make',
								),
							),
							const SizedBox(height: 16),
							TextField(
								controller: _modelController,
								decoration: const InputDecoration(
									labelText: 'Model',
								),
							),
							const SizedBox(height: 16),
							TextField(
								controller: _colorController,
								decoration: const InputDecoration(
									labelText: 'Color',
								),
							),
							const SizedBox(height: 32),
							const Text(
								'Estimated Park Time',
								style: TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 16),
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									NumberPicker(
										value: _hours,
										minValue: 0,
										maxValue: 10,
										infiniteLoop: true,
										onChanged: (value) => setState(() => _hours = value),
									),
									const SizedBox(width: 16),
									const Text('hours'),
									const SizedBox(width: 32),
									NumberPicker(
										value: _minutes,
										minValue: 0,
										step: 5,
										infiniteLoop: true,
										maxValue: 59,
										onChanged: (value) => setState(() => _minutes = value),
									),
									const SizedBox(width: 16),
									const Text('mins'),
								],
							),
							const SizedBox(height: 32),
							Center(
								child: ElevatedButton(
									onPressed: _navigateToConfirmationPage,
									child: const Text('Continue'),
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

class ConfirmationPage extends StatelessWidget {
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
				],
			),
    );
  }
}