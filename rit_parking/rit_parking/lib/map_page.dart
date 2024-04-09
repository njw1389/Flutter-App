import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:rit_parking/lot_page.dart';

class MapPage extends StatefulWidget {
	const MapPage({super.key});

	@override
	_MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
	GoogleMapController? _mapController;
  	LatLng? _userLocation;
  	// String _searchQuery = '';
  	final Set<Marker> _markers = {};
  	Marker? _userLocationMarker;

	@override
	void initState() {
		super.initState();
		_getUserLocation();
		_initializeMarkers();
	}

	void _getUserLocation() async {
		try {
			Position position = await Geolocator.getCurrentPosition(
				desiredAccuracy: LocationAccuracy.medium,
			);
			setState(() {
				_userLocation = LatLng(position.latitude, position.longitude);
				_userLocationMarker = Marker(
				markerId: const MarkerId('userLocation'),
				position: _userLocation!,
				icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
				);
			});
		} catch (e) {
			// Handle location retrieval errors
			print('Error retrieving location: $e');
		}
	}

	void _onMapCreated(GoogleMapController controller) {
    	_mapController = controller;
  	}

	void _centerMapOnUserLocation() {
		if (_userLocation != null) {
			_mapController?.animateCamera(
				CameraUpdate.newLatLng(_userLocation!),
			);
		}
	}

	void _onMarkerTap(MarkerId markerId) {
		Navigator.push(
			context,
			MaterialPageRoute(builder: (context) => LotPage(lotId: markerId.value)),
		);
	}

	void _onSearchSubmitted(String query) {
		setState(() {
			// _searchQuery = query;
		});
		// Perform search logic based on the query
		// Update the markers or navigate to the search result
	}

	Future<BitmapDescriptor> _createCustomMarkerIcon(String lotLetter) async {
		final pictureRecorder = PictureRecorder();
		final canvas = Canvas(pictureRecorder);
		final paintFill = Paint()..color = const Color.fromRGBO(247, 105, 2, 1);

		const radius = 24.0;
		const circleOffset = Offset(radius, radius);

		canvas.drawCircle(circleOffset, radius, paintFill);

		final textSpan = TextSpan(
			text: lotLetter,
			style: const TextStyle(
				fontSize: 24.0,
				fontWeight: FontWeight.bold,
				color: Colors.white,
			),
		);
		
		final textPainter = TextPainter(
			text: textSpan,
			textDirection: TextDirection.ltr,
		);

		textPainter.layout();

		final textOffset = Offset(
			radius - textPainter.width / 2,
			radius - textPainter.height / 2,
		);

		textPainter.paint(canvas, textOffset);

		final picture = pictureRecorder.endRecording();
		final image = await picture.toImage(radius.toInt() * 2, radius.toInt() * 2);
		final bytes = await image.toByteData(format: ImageByteFormat.png);

		return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
	}

	void _initializeMarkers() async {
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
		return Scaffold(
			appBar: AppBar(
				title: const Text(
					'RIT Parking',
					style: TextStyle(color: Colors.white),
				),
				backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
				iconTheme: const IconThemeData(color: Colors.white),
			),
			body: _userLocation == null
				? const Center(
					child: CircularProgressIndicator(
						valueColor: AlwaysStoppedAnimation<Color>(
							Color.fromRGBO(247, 105, 2, 1),
						),
					),
				)
				: Stack(
					children: [
						GoogleMap(
							onMapCreated: _onMapCreated,
							initialCameraPosition: CameraPosition(
								target: _userLocation!,
								zoom: 15.0,
							),
							markers: {
								..._markers,
								if (_userLocationMarker != null) _userLocationMarker!,
							},
							mapType: MapType.normal,
						),
						Positioned(
							top: 16,
							left: 16,
							right: 16,
							child: Container(
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(24.0),
									boxShadow: [
										BoxShadow(
											color: Colors.black.withOpacity(0.1),
											blurRadius: 4,
											offset: const Offset(0, 2),
										),
									],
								),
								child: TextField(
									decoration: const InputDecoration(
										hintText: 'Search by lot or building...',
										border: InputBorder.none,
										contentPadding: EdgeInsets.symmetric(
											horizontal: 16.0,
											vertical: 12.0,
										),
										prefixIcon: Icon(Icons.search),
									),
									onSubmitted: _onSearchSubmitted,
								),
							),
						),
						Positioned(
							bottom: 16,
							left: 0,
							right: 0,
							child: Container(
								alignment: Alignment.center,
								child: FloatingActionButton(
									onPressed: _centerMapOnUserLocation,
									backgroundColor: const Color.fromRGBO(247, 105, 2, 1),
									foregroundColor: Colors.white,
									child: const Icon(Icons.my_location),
								),
							),
						),
					],
				),
			);
	}
}