import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:rit_parking/reservations_page.dart';
import 'package:rit_parking/favorites_page.dart';
import 'package:rit_parking/confirmation_page.dart';

  // So for the reservation flow, we need to save the user's information to a CSV file user_data.csv on this page to pass
  // to the confirmation page so we clear that file everytime a user visits the page so it's empty for new reservation info.

class UserInfoPage extends StatefulWidget {
  final String lotId;

  const UserInfoPage({super.key, required this.lotId});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  // Text controllers for user input fields
  final TextEditingController _firstLastNameController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _stateRegisteredController = TextEditingController();

  // Flag to track the drawer state (open or closed)
  bool isDrawerOpen = false;

  // List of state options for the dropdown menu
  final List<String> _stateOptions = [
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
    'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
    'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
    'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
    'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming',
    'District of Columbia', 'American Samoa', 'Guam', 'Northern Mariana Islands', 'Puerto Rico', 'U.S. Virgin Islands'
  ];

  // Map of car make and model options for the dropdown menus
  final Map<String, List<String>> _makeModelOptions = {
    'Acura': ['ILX', 'MDX', 'RDX', 'RLX', 'TLX'],
    'Alfa Romeo': ['4C', 'Giulia', 'Stelvio'],
    'Aston Martin': ['DB11', 'DBS', 'DBX', 'Vantage'],
    'Audi': ['A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'e-tron', 'Q3', 'Q4', 'Q5', 'Q7', 'Q8', 'R8', 'TT'],
    'Bentley': ['Bentayga', 'Continental', 'Flying Spur', 'Mulsanne'],
    'BMW': ['1 Series', '2 Series', '3 Series', '4 Series', '5 Series', '6 Series', '7 Series', '8 Series', 'i3', 'i4', 'iX', 'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7', 'Z4'],
    'Buick': ['Enclave', 'Encore', 'Envision', 'LaCrosse', 'Regal'],
    'Cadillac': ['ATS', 'CT4', 'CT5', 'CT6', 'Escalade', 'XT4', 'XT5', 'XT6'],
    'Chevrolet': ['Blazer', 'Bolt', 'Camaro', 'Colorado', 'Corvette', 'Equinox', 'Malibu', 'Silverado', 'Spark', 'Suburban', 'Tahoe', 'Trailblazer', 'Traverse', 'Trax'],
    'Dodge': ['Avenger', 'Challenger', 'Charger', 'Dart', 'Durango', 'Grand Caravan', 'Journey', 'Viper'],
    'Ferrari': ['California', 'F8', 'FF', 'GTC4Lusso', 'Portofino', 'Roma', 'SF90'],
    'Ford': ['Bronco', 'Bronco Sport', 'EcoSport', 'Edge', 'Escape', 'Expedition', 'Explorer', 'F-150', 'Fiesta', 'Flex', 'Focus', 'Fusion', 'Mustang', 'Ranger', 'Taurus'],
    'Genesis': ['G70', 'G80', 'G90', 'GV70', 'GV80'],
    'GMC': ['Acadia', 'Canyon', 'Hummer EV', 'Sierra', 'Terrain', 'Yukon'],
    'Honda': ['Accord', 'Civic', 'Clarity', 'CR-V', 'CR-Z', 'Fit', 'HR-V', 'Insight', 'Odyssey', 'Passport', 'Pilot', 'Ridgeline'],
    'Hyundai': ['Accent', 'Azera', 'Elantra', 'Equus', 'Genesis', 'Ioniq', 'Kona', 'Nexo', 'Palisade', 'Santa Cruz', 'Santa Fe', 'Sonata', 'Tucson', 'Veloster', 'Venue'],
    'INFINITI': ['Q30', 'Q40', 'Q50', 'Q60', 'Q70', 'QX30', 'QX50', 'QX55', 'QX60', 'QX70', 'QX80'],
    'Jaguar': ['E-PACE', 'F-PACE', 'F-TYPE', 'I-PACE', 'S-Type', 'X-Type', 'XE', 'XF', 'XJ'],
    'Jeep': ['Cherokee', 'Compass', 'Gladiator', 'Grand Cherokee', 'Liberty', 'Patriot', 'Renegade', 'Wrangler'],
    'Kia': ['Cadenza', 'Carnival', 'Forte', 'K5', 'K900', 'Niro', 'Optima', 'Rio', 'Sedona', 'Seltos', 'Sorento', 'Soul', 'Sportage', 'Stinger', 'Telluride'],
    'Lamborghini': ['Aventador', 'Gallardo', 'Huracan', 'Murcielago', 'Urus'],
    'Land Rover': ['Defender', 'Discovery', 'Discovery Sport', 'Freelander', 'LR2', 'LR3', 'LR4', 'Range Rover', 'Range Rover Evoque', 'Range Rover Sport', 'Range Rover Velar'],
    'Lexus': ['CT', 'ES', 'GS', 'GX', 'HS', 'IS', 'LC', 'LFA', 'LS', 'LX', 'NX', 'RC', 'RX', 'SC', 'UX'],
    'Lincoln': ['Aviator', 'Blackwood', 'Continental', 'Corsair', 'LS', 'Mark LT', 'Mark VII', 'Mark VIII', 'MKC', 'MKS', 'MKT', 'MKX', 'MKZ', 'Nautilus', 'Navigator', 'Town Car', 'Zephyr'],
    'Lotus': ['Elise', 'Esprit', 'Evija', 'Evora', 'Exige'],
    'Maserati': ['Ghibli', 'GranTurismo', 'Levante', 'MC20', 'Quattroporte'],
    'Mazda': ['CX-3', 'CX-30', 'CX-5', 'CX-7', 'CX-9', 'MX-5 Miata', 'RX-8'],
    'McLaren': ['540C', '570S', '600LT', '650S', '675LT', '720S', '765LT', 'Artura', 'GT', 'MP4-12C', 'P1', 'Senna'],
    'Mercedes-Benz': ['A-Class', 'B-Class', 'C-Class', 'CLA', 'CLS', 'E-Class', 'G-Class', 'GL-Class', 'GLA', 'GLB', 'GLC', 'GLE', 'GLK', 'GLS', 'M-Class', 'R-Class', 'S-Class', 'SL', 'SLC', 'SLK', 'SLR McLaren', 'SLS AMG'],
    'MINI': ['Clubman', 'Convertible', 'Cooper', 'Countryman', 'Hardtop', 'Paceman'],
    'Mitsubishi': ['3000GT', 'Eclipse', 'Eclipse Cross', 'Endeavor', 'Galant', 'i-MiEV', 'Lancer', 'Mirage', 'Montero', 'Outlander', 'Outlander PHEV', 'Outlander Sport', 'RVR'],
    'Nissan': ['200SX', '240SX', '300ZX', '350Z', '370Z', 'Altima', 'Armada', 'Cube', 'Frontier', 'GT-R', 'Juke', 'Kicks', 'LEAF', 'Maxima', 'Murano', 'NV', 'NV200', 'Pathfinder', 'Quest', 'Rogue', 'Sentra', 'Titan', 'Versa', 'Xterra'],
    'Porsche': ['718 Boxster', '718 Cayman', '918 Spyder', 'Cayenne', 'Cayman', 'Macan', 'Panamera', 'Taycan'],
    'Ram': ['Dakota', 'ProMaster', 'ProMaster City'],
    'Rolls-Royce': ['Cullinan', 'Dawn', 'Ghost', 'Phantom', 'Silver Seraph', 'Wraith'],
    'Scion': ['FR-S', 'iA', 'iM', 'iQ', 'tC', 'xA', 'xB', 'xD'],
    'smart': ['fortwo'],
    'Subaru': ['Ascent', 'Baja', 'BRZ', 'Crosstrek', 'Forester', 'Impreza', 'Legacy', 'Outback', 'SVX', 'Tribeca', 'WRX', 'XV Crosstrek'],
    'Tesla': ['Model 3', 'Model S', 'Model X', 'Model Y', 'Roadster'],
    'Toyota': ['4Runner', 'Avalon', 'C-HR', 'Camry', 'Celica', 'Corolla', 'Echo', 'FJ Cruiser', 'GR86', 'Highlander', 'Land Cruiser', 'Matrix', 'MR2', 'Prius', 'RAV4', 'Sequoia', 'Sienna', 'Solara', 'Supra', 'Tacoma', 'Tercel', 'Tundra', 'Venza', 'Yaris'],
    'Volkswagen': ['Arteon', 'Atlas', 'Beetle', 'Cabrio', 'CC', 'Corrado', 'Eos', 'Eurovan', 'Fox', 'GLI', 'Golf', 'GTI', 'ID.4', 'Jetta', 'Karmann Ghia', 'Passat', 'Phaeton', 'Rabbit', 'Routan', 'Scirocco', 'Taos', 'Thing', 'Tiguan', 'Touareg'],
    'Volvo': ['C30', 'C70', 'S40', 'S60', 'S70', 'S80', 'S90', 'V40', 'V50', 'V60', 'V70', 'V90', 'XC40', 'XC60', 'XC70', 'XC90'],
  };

  // List of color options for the dropdown menu
  final List<String> _colorOptions = [
    'Black', 'Blue', 'Brown', 'Gold', 'Gray', 'Green', 'Orange', 'Purple', 'Red', 'Silver', 'Tan', 'White', 'Yellow', 'Other',
  ];

  // Selected values for make, model, and color dropdown menus
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedColor;

  // Variables to store the selected hours and minutes for park time
  int _hours = 0;
  int _minutes = 15;

  @override
  void initState() {
    super.initState();
    // Clear the CSV file on page initialization
    _clearCSVFile();
  }

  // Method to clear the contents of the CSV file
  void _clearCSVFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/user_data.csv');
    await file.writeAsString('');
  }

  // Method to save user data to a CSV file
  void _saveDataToCSV() async {
    final minutesFormatted = _minutes.toString().padLeft(2, '0');
    final data = [
      [
        _firstLastNameController.text,
        _licensePlateController.text,
        _stateRegisteredController.text,
        _selectedMake,
        _selectedModel,
        _selectedColor,
        '$_hours:$minutesFormatted',
        DateTime.now().millisecondsSinceEpoch.toString(),
        widget.lotId,
      ],
    ];

    String csvData = const ListToCsvConverter().convert(data);
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    // Save data to user_data.csv
    final userDataFile = File('$path/user_data.csv');
    await userDataFile.writeAsString(csvData);
  }

  // Method to navigate to the confirmation page
  void _navigateToConfirmationPage() {
    // Check if any required fields are empty
    if (_firstLastNameController.text.isEmpty ||
        _licensePlateController.text.isEmpty ||
        _stateRegisteredController.text.isEmpty ||
        _selectedMake == null ||
        _selectedModel == null ||
        _selectedColor == null) {
      // Show an error message or dialog for missing information
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Missing Information',
            style: TextStyle(
              color: Color.fromRGBO(247, 105, 2, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Please fill out all fields.',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color.fromRGBO(247, 105, 2, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
      return;
    }

    // Check if the selected park time is invalid (0 hours and 0 minutes)
    if (_hours == 0 && _minutes == 0) {
      // Show an error message or dialog for invalid reservation duration
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Invalid Park Time',
            style: TextStyle(
              color: Color.fromRGBO(247, 105, 2, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'You cannot reserve for 0 hours and 0 minutes.',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color.fromRGBO(247, 105, 2, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
      return;
    }

    // Save user data to CSV file
    _saveDataToCSV();
    // Navigate to the confirmation page
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
        actions: [
          IconButton(
            icon: isDrawerOpen ? const Icon(Icons.close) : const Icon(Icons.menu),
            onPressed: () {
              setState(() {
                isDrawerOpen = !isDrawerOpen;
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
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First and Last Name TextField
                          TextField(
                            controller: _firstLastNameController,
                            decoration: const InputDecoration(
                              labelText: 'First & Last Name',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(247, 105, 2, 1)),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Color.fromRGBO(247, 105, 2, 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // License Plate TextField
                          TextField(
                            controller: _licensePlateController,
                            decoration: const InputDecoration(
                              labelText: 'License Plate',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(247, 105, 2, 1)),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Color.fromRGBO(247, 105, 2, 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // State Registered DropdownButtonFormField
                          DropdownButtonFormField<String>(
                            value: _stateRegisteredController.text.isNotEmpty ? _stateRegisteredController.text : null,
                            onChanged: (value) {
                              setState(() {
                                _stateRegisteredController.text = value!;
                              });
                            },
                            items: _stateOptions.map((state) {
                              return DropdownMenuItem<String>(
                                value: state,
                                child: Text(state),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: 'State Registered',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(247, 105, 2, 1)),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Color.fromRGBO(247, 105, 2, 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Make DropdownButtonFormField
                          DropdownButtonFormField<String>(
                            value: _selectedMake,
                            onChanged: (value) {
                              setState(() {
                                _selectedMake = value;
                                _selectedModel = null;
                              });
                            },
                            items: _makeModelOptions.keys.map((make) {
                              return DropdownMenuItem<String>(
                                value: make,
                                child: Text(make),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: 'Make',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(247, 105, 2, 1)),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Color.fromRGBO(247, 105, 2, 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Model DropdownButtonFormField
                          DropdownButtonFormField<String>(
                            value: _selectedModel,
                            onChanged: _selectedMake != null
                                ? (value) {
                                    setState(() {
                                      _selectedModel = value;
                                    });
                                  }
                                : null,
                            items: _selectedMake != null
                                ? _makeModelOptions[_selectedMake]!.map((model) {
                                    return DropdownMenuItem<String>(
                                      value: model,
                                      child: Text(model),
                                    );
                                  }).toList()
                                : [],
                            decoration: const InputDecoration(
                              labelText: 'Model',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(247, 105, 2, 1)),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Color.fromRGBO(247, 105, 2, 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Color DropdownButtonFormField
                          DropdownButtonFormField<String>(
                            value: _selectedColor,
                            onChanged: (value) {
                              setState(() {
                                _selectedColor = value;
                              });
                            },
                            items: _colorOptions.map((color) {
                              return DropdownMenuItem<String>(
                                value: color,
                                child: Text(color),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: 'Color',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(247, 105, 2, 1)),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Color.fromRGBO(247, 105, 2, 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Estimated Park Time label
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Estimated Park Time',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Estimated Park Time picker
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                // Hours NumberPicker
                                SizedBox(
                                  width: 80, // Set the width of the number picker wheel
                                  child: NumberPicker(
                                    value: _hours,
                                    minValue: 0,
                                    maxValue: 10,
                                    infiniteLoop: false,
                                    onChanged: (value) {
                                      setState(() {
                                        _hours = value;
                                        if (_hours == 0 && _minutes == 0) {
                                          _minutes = 5; // Set minutes to 5 when hours change to 0 and minutes are 0
                                        }
                                      });
                                    },
                                    selectedTextStyle: const TextStyle(
                                      color: Color.fromRGBO(247, 105, 2, 1),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    itemWidth: 60,
                                    itemCount: 3,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('hours'),
                                const SizedBox(width: 8),
                                // Minutes NumberPicker
                                SizedBox(
                                  width: 100, // Set the width of the number picker wheel
                                  child: NumberPicker(
                                    value: _minutes,
                                    minValue: 0,
                                    step: 5,
                                    infiniteLoop: false,
                                    maxValue: 59,
                                    onChanged: (value) => setState(() => _minutes = value),
                                    selectedTextStyle: const TextStyle(
                                      color: Color.fromRGBO(247, 105, 2, 1),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    itemWidth: 60,
                                    itemCount: 3,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('mins'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Continue button
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _navigateToConfirmationPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Continue',
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
              color: isDrawerOpen ? const Color.fromRGBO(247, 105, 2, 1) : Colors.transparent,
              child: ListView(
                children: [
                  // Reservations menu item
                  InkWell(
                    onTap: () {
                      // Navigate to the reservations page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReservationsPage()
                        ),
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
                  // Favorites menu item
                  InkWell(
                    onTap: () {
                      // Navigate to the favorites page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesPage()
                        ),
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