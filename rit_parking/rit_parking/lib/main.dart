import 'package:flutter/material.dart';
import 'package:rit_parking/map_page.dart';

void main() {
  	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'RIT Parking',
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			home: const MapPage(),
			debugShowCheckedModeBanner: false,
		);
	}
}