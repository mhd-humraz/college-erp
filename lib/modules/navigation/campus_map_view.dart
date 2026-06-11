// lib/modules/navigation/campus_map_view.dart
import 'package:flutter/material.dart';

class CampusMapView extends StatelessWidget {
  const CampusMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Spatial Navigation')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBar(
                leading: const Icon(Icons.search),
                hintText: 'Search room, lab, or office coordinates...',
                onSubmitted: (value) {
                  // Highlight specific matching point of interest coordinates below
                },
              ),
            ),
            // The Coordinate Mapping Canvas Node
            InteractiveViewer(
              maxScale: 4.0,
              child: Stack(
                children: [
                  // Placeholder for high-resolution canvas map asset upload
                  Container(
                    width: double.infinity,
                    height: 450,
                    color: Colors.blueGrey.shade100,
                    child: const Center(child: Icon(Icons.map_outlined, size: 80, color: Colors.blueGrey)),
                  ),
                  // Custom Marker Points of Interest laid over coordinate points
                  const Positioned(
                    left: 80,
                    top: 150,
                    child: Tooltip(
                      message: 'Main Computer Science Research Laboratory 1',
                      child: Icon(Icons.location_on, color: Colors.red, size: 36),
                    ),
                  ),
                  const Positioned(
                    left: 220,
                    top: 280,
                    child: Tooltip(
                      message: 'Central Library Main Complex Entrance',
                      child: Icon(Icons.location_on, color: Colors.darkWithAccent, size: 36),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}