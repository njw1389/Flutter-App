import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rit_parking/lot_page.dart';
import 'package:rit_parking/reservations_page.dart';
import 'package:rit_parking/favorites_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  // Controller for the Google Map
  GoogleMapController? _mapController;
  
  // User's current location
  LatLng? _userLocation;
  
  // Set of markers to be displayed on the map
  final Set<Marker> _markers = {};
  
  // Marker representing the user's location
  Marker? _userLocationMarker;
  
  // Track the state of the side menu
  bool isDrawerOpen = false;
  
  // Flag to indicate if the user has active reservations
  bool _hasActiveReservations = false;
  
  // Timer to periodically check for active reservations
  Timer? _reservationTimer;
  
  // Flag to track if the banner was manually closed by the user
  bool _bannerManuallyClosedByUser = false;

  // RIT coordinates
  static const LatLng _ritLocation = LatLng(43.08599208491002, -77.67446841275189);

  @override
  void initState() {
    super.initState();
    // Add the widget as an observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Check for active reservations and start the reservation timer if necessary
    _checkActiveReservations().then((_) {
      if (_hasActiveReservations) {
        _startReservationTimer();
      }
    });
    
    // Get the user's location
    _getUserLocation();
    
    // Initialize the markers on the map
    _initializeMarkers();
    
    // Center the map on RIT's location
    _centerMapOnRIT();
  }

  // Stop the reservation timer
  void _stopReservationTimer() {
    _reservationTimer?.cancel();
    _reservationTimer = null;
  }

  // Start the reservation timer to periodically check for active reservations
  void _startReservationTimer() {
    _reservationTimer?.cancel(); // Cancel any existing timer
    _reservationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkActiveReservations();
    });
  }

  @override
  void dispose() {
    // Remove the widget as an observer for app lifecycle changes
    WidgetsBinding.instance.removeObserver(this);
    // Cancel the reservation timer when the widget is disposed
    _reservationTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When the app is resumed, check for active reservations and start the timer if necessary
    if (state == AppLifecycleState.resumed) {
      _checkActiveReservations().then((_) {
        if (_hasActiveReservations) {
          _startReservationTimer();
        }
      });
    }
  }

  // Check for active reservations by reading the reservations CSV file
  Future<void> _checkActiveReservations() async {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    
    // Get the path to the directory
    final path = directory.path;
    
    // Create a File object pointing to the 'reservations.csv' file
    final file = File('$path/reservations.csv');
    
    // Check if the file exists
    if (await file.exists()) {
      // Read the contents of the file as a string
      final csvString = await file.readAsString();
      
      // Split the string into rows using newline character
      final rows = csvString.split('\n');
      
      // Process the rows
      final data = rows
          .map((row) => row.trim()) // Trim whitespace from each row
          .where((row) => row.isNotEmpty) // Filter out empty rows
          .map((row) => const CsvToListConverter().convert(row).first) // Convert each row to a list
          .toList(); // Convert the iterable to a list
      
      // Filter active reservations
      final activeReservations = data.where((reservation) {
        // Parse the creation time from milliseconds to DateTime
        final creationTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(reservation[7].toString()),
        );
        
        // Split the estimated park time into hours and minutes
        final estimatedParkTime = reservation[6].toString().trim().split(':');
        int estimatedHours = 0, estimatedMinutes = 0;
        
        // Check if the estimated park time has both hours and minutes
        if (estimatedParkTime.length == 2) {
          // Parse the hours and minutes from strings to integers
          estimatedHours = int.tryParse(estimatedParkTime[0]) ?? 0;
          estimatedMinutes = int.tryParse(estimatedParkTime[1]) ?? 0;
        }
        
        // Create a Duration object from the estimated hours and minutes
        final estimatedDuration = Duration(hours: estimatedHours, minutes: estimatedMinutes);
        
        // Calculate the elapsed duration since the creation time
        final elapsedDuration = DateTime.now().difference(creationTime);
        
        // Calculate the remaining duration by subtracting the elapsed duration from the estimated duration
        final remainingDuration = estimatedDuration - elapsedDuration;
        
        // Check if the remaining duration is greater than 0 seconds
        return remainingDuration.inSeconds > 0;
      }).toList();
      
      // Update the state
      setState(() {
        // Set the _hasActiveReservations flag based on the presence of active reservations
        _hasActiveReservations = activeReservations.isNotEmpty;
        
        // Check if there are active reservations and the banner is not manually closed by the user
        if (_hasActiveReservations && !_bannerManuallyClosedByUser) {
          // Start the reservation timer
          _startReservationTimer();
        } else {
          // Stop the reservation timer
          _stopReservationTimer();
        }
      });
    }
  }

  // Create a custom marker icon for the user's location
  Future<BitmapDescriptor> _createUserLocationMarkerIcon() async {
    // Create a PictureRecorder to record the canvas commands
    final pictureRecorder = PictureRecorder();
    
    // Create a Canvas with the PictureRecorder
    final canvas = Canvas(pictureRecorder);
    
    // Create a Paint object for the fill color (RIT orange)
    final paintFill = Paint()..color = const Color.fromRGBO(247, 105, 2, 1);
    
    // Define the radius of the marker
    const radius = 60.0;
    
    // Define the offset to center the circle within the marker
    const circleOffset = Offset(radius, radius);
    
    // Draw the outer circle with the fill color
    canvas.drawCircle(circleOffset, radius, paintFill);
    
    // Create a Paint object for the center color (white)
    final paintCenter = Paint()..color = Colors.white;
    
    // Draw the inner circle with the center color
    canvas.drawCircle(circleOffset, radius - 24, paintCenter);
    
    // End the recording and obtain the recorded picture
    final picture = pictureRecorder.endRecording();
    
    // Convert the picture to an image with the specified dimensions
    final image = await picture.toImage(radius.toInt() * 2, radius.toInt() * 2);
    
    // Convert the image to byte data in PNG format
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    
    // Create a BitmapDescriptor from the byte data and return it
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  // Request location permission from the user
  Future<void> _requestLocationPermission() async {
    // Request location permission using the Geolocator package
    LocationPermission permission = await Geolocator.requestPermission();
    
    if (permission == LocationPermission.denied) {
      // If location permission is denied, show a dialog to inform the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
            title: const Text(
              'Location Permission Denied',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Please grant location permission to use this app.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Dismiss the dialog when the OK button is pressed
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    } else if (permission == LocationPermission.deniedForever) {
      // If location permission is permanently denied, show a dialog to inform the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
            title: const Text(
              'Location Permission Permanently Denied',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'You have permanently denied location permission for this app. Please go to app settings and grant location permission.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Dismiss the dialog when the OK button is pressed
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  // Get the user's location
  void _getUserLocation() async {
    try {
      // Request location permission
      await _requestLocationPermission();

      LatLng defaultLocation;

      if (kReleaseMode) {
        // Running on a real device
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        defaultLocation = LatLng(position.latitude, position.longitude);
      } else {
        // Running on an emulator
        // Set default location coordinates
        defaultLocation = const LatLng(43.086416282661126, -77.65563199211316);
      }

      setState(() async {
        _userLocation = defaultLocation;
        _userLocationMarker = Marker(
          markerId: const MarkerId('userLocation'),
          position: _userLocation!,
          icon: await _createUserLocationMarkerIcon(),
        );
      });
    } catch (e) {
      // Handle location retrieval errors
      print('Error retrieving location: $e');
    }
  }

  // Callback function when the map is created
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _centerMapOnRIT();
  }

  // Center the map on the user's location
  void _centerMapOnUserLocation() {
    if (_userLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _userLocation!,
            zoom: 14.35, // Set the desired zoom level here
          ),
        ),
      );
    }
  }

  // Center the map on RIT's location
  void _centerMapOnRIT() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _ritLocation,
          zoom: 14.35, // Set the desired zoom level here
        ),
      ),
    );
  }

  // Center the map on a specific location
  void _centerMapOnLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(location),
    );
  }

  // Callback function when a marker is tapped
  void _onMarkerTap(MarkerId markerId) {
    // Navigate to the LotPage with the tapped marker's lot ID
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LotPage(lotId: markerId.value)),
    );
  }

  // Create a custom marker icon with the lot letter
  Future<BitmapDescriptor> _createCustomMarkerIcon(String lotLetter) async {
    // Create a PictureRecorder to record the canvas commands
    final pictureRecorder = PictureRecorder();
    
    // Create a Canvas with the PictureRecorder
    final canvas = Canvas(pictureRecorder);
    
    // Create a Paint object for the fill color (RIT orange)
    final paintFill = Paint()..color = const Color.fromRGBO(247, 105, 2, 1);
    
    // Define the radius of the marker
    const radius = 60.0;
    
    // Define the offset to center the circle within the marker
    const circleOffset = Offset(radius, radius);
    
    // Draw the circle with the fill color
    canvas.drawCircle(circleOffset, radius, paintFill);
    
    // Create a TextSpan with the lot letter
    final textSpan = TextSpan(
      text: lotLetter,
      style: const TextStyle(
        fontSize: 60.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
    
    // Create a TextPainter to paint the text
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    // Layout the text painter to calculate the text dimensions
    textPainter.layout();
    
    // Calculate the offset to center the text within the marker
    final textOffset = Offset(
      radius - textPainter.width / 2,
      radius - textPainter.height / 2,
    );
    
    // Paint the text on the canvas at the calculated offset
    textPainter.paint(canvas, textOffset);
    
    // End the recording and obtain the recorded picture
    final picture = pictureRecorder.endRecording();
    
    // Convert the picture to an image with the specified dimensions
    final image = await picture.toImage(radius.toInt() * 2, radius.toInt() * 2);
    
    // Convert the image to byte data in PNG format
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    
    // Create a BitmapDescriptor from the byte data and return it
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  // Initialize the markers on the map
  void _initializeMarkers() async {
    // Create custom marker icons for each lot
    final lotSIcon = await _createCustomMarkerIcon('S');
    final lotGVIcon = await _createCustomMarkerIcon('GV');
    final lotTIcon = await _createCustomMarkerIcon('T');
    final lotJIcon = await _createCustomMarkerIcon('J');
    final lotFIcon = await _createCustomMarkerIcon('F');
    final lotGIcon = await _createCustomMarkerIcon('G');
    final lotEIcon = await _createCustomMarkerIcon('E');
    final lotDIcon = await _createCustomMarkerIcon('D');
    final lotNIcon = await _createCustomMarkerIcon('N');
    final lotHIcon = await _createCustomMarkerIcon('H');
    final lotLIcon = await _createCustomMarkerIcon('L');
    final lotCIcon = await _createCustomMarkerIcon('C');
    final lotKIcon = await _createCustomMarkerIcon('K');
    final lotMIcon = await _createCustomMarkerIcon('M');
    final lotBIcon = await _createCustomMarkerIcon('B');
    final lotAIcon = await _createCustomMarkerIcon('A');
    final lotUIcon = await _createCustomMarkerIcon('U');

    setState(() {
      // Add markers for each lot with their respective icons and positions
      _markers.addAll([
        Marker(
          markerId: const MarkerId('Global Village'),
          position: const LatLng(43.08403582310675, -77.68385635031422),
          onTap: () => _onMarkerTap(const MarkerId('Global Village')),
          icon: lotGVIcon,
        ),
        Marker(
          markerId: const MarkerId('S'),
          position: const LatLng(43.08190037047487 - 0.000275, -77.68048854233905 + 0.000175),
          onTap: () => _onMarkerTap(const MarkerId('S')),
          icon: lotSIcon,
        ),
        Marker(
          markerId: const MarkerId('T'),
          position: const LatLng(43.08613350901658, -77.68221608763827),
          onTap: () => _onMarkerTap(const MarkerId('T')),
          icon: lotTIcon,
        ),
        Marker(
          markerId: const MarkerId('J'),
          position: const LatLng(43.086645265619175, -77.68037918734635),
          onTap: () => _onMarkerTap(const MarkerId('J')),
          icon: lotJIcon,
        ),
        Marker(
          markerId: const MarkerId('F'),
          position: const LatLng(43.08690845308434, -77.6782569919219),
          onTap: () => _onMarkerTap(const MarkerId('F')),
          icon: lotFIcon,
        ),
        Marker(
          markerId: const MarkerId('G'),
          position: const LatLng(43.0884254142541, -77.6762248897014),
          onTap: () => _onMarkerTap(const MarkerId('G')),
          icon: lotGIcon,
        ),
        Marker(
          markerId: const MarkerId('E'),
          position: const LatLng(43.086497639205014, -77.67612172994299),
          onTap: () => _onMarkerTap(const MarkerId('E')),
          icon: lotEIcon,
        ),
        Marker(
          markerId: const MarkerId('D'),
          position: const LatLng(43.0866881668546, -77.67338610887062),
          onTap: () => _onMarkerTap(const MarkerId('D')),
          icon: lotDIcon,
        ),
        Marker(
          markerId: const MarkerId('N'),
          position: const LatLng(43.088201585915634 - 0.000075, -77.67301297005037),
          onTap: () => _onMarkerTap(const MarkerId('N')),
          icon: lotNIcon,
        ),
        Marker(
          markerId: const MarkerId('H'),
          position: const LatLng(43.08839854949241, -77.67787987716865),
          onTap: () => _onMarkerTap(const MarkerId('H')),
          icon: lotHIcon,
        ),
        Marker(
          markerId: const MarkerId('L'),
          position: const LatLng(43.08719470117787, -77.6668282266198),
          onTap: () => _onMarkerTap(const MarkerId('L')),
          icon: lotLIcon,
        ),
        Marker(
          markerId: const MarkerId('C'),
          position: const LatLng(43.08339083790623, -77.66703747676186),
          onTap: () => _onMarkerTap(const MarkerId('C')),
          icon: lotCIcon,
        ),
        Marker(
          markerId: const MarkerId('K'),
          position: const LatLng(43.0855782775444, -77.66520228922656),
          onTap: () => _onMarkerTap(const MarkerId('K')),
          icon: lotKIcon,
        ),
        Marker(
          markerId: const MarkerId('M'),
          position: const LatLng(43.0861909358135, -77.66970785820138),
          onTap: () => _onMarkerTap(const MarkerId('M')),
          icon: lotMIcon,
        ),
        Marker(
          markerId: const MarkerId('B'),
          position: const LatLng(43.08368704378063, -77.66344735318712),
          onTap: () => _onMarkerTap(const MarkerId('B')),
          icon: lotBIcon,
        ),
        Marker(
          markerId: const MarkerId('A'),
          position: const LatLng(43.083731313483014, -77.66201523829903),
          onTap: () => _onMarkerTap(const MarkerId('A')),
          icon: lotAIcon,
        ),
        Marker(
          markerId: const MarkerId('U'),
          position: const LatLng(43.081733087311775, -77.67424995945802),
          onTap: () => _onMarkerTap(const MarkerId('U')),
          icon: lotUIcon,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a splash screen while loading the user's location and markers
    return _userLocation == null || _markers.isEmpty ? const SplashScreen() : Scaffold(
      appBar: AppBar(
        title: const Text(
          'RIT Parking',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
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
                  InkWell(
                    onTap: () {
                      // Navigate to the reservations page
                      Navigator.push(
                        context,
                        MaterialPageRoute( builder: (context) => const ReservationsPage() ),
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
                        MaterialPageRoute( builder: (context) => const FavoritesPage() ),
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
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: const CameraPosition(
                    target: _ritLocation,
                    zoom: 14.35,
                  ),
                  markers: {
                    ..._markers,
                    if (_userLocationMarker != null) _userLocationMarker!,
                  },
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  minMaxZoomPreference: const MinMaxZoomPreference(
                    10.0, // Set the minimum zoom level here
                    18.0, // Set the maximum zoom level here
                  ),
                ),
                // Banner indicating active reservations
                if (_hasActiveReservations)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReservationsPage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Colors.black,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _hasActiveReservations = false;
                                        _bannerManuallyClosedByUser = true;
                                        _stopReservationTimer(); // Stop the timer when the banner is closed
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 0.0),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'You already have a reservation or more',
                                    style: TextStyle(
                                      color: Color.fromRGBO(247, 105, 2, 1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ReservationsPage(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'Visit Reservations',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ), 
                  // Floating action buttons for centering the map
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: _centerMapOnUserLocation,
                          backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.my_location),
                        ),
                        const SizedBox(width: 16),
                        FloatingActionButton(
                          onPressed: _centerMapOnRIT,
                          backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.location_city),
                        ),
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

// Splash screen shown while loading the user's location and markers
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}