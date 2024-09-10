import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:readygreen/bottom_navigation.dart';

void main() => runApp(const MapPage());

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(36.354946759143, 127.29980994578);

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // 위치 정보를 받아오는 함수
  Future<void> _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    LocationData currentLocation;
    var location = Location();

    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = LocationData.fromMap({
        'latitude': _center.latitude,
        'longitude': _center.longitude,
      });
    }

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 14.0,
      ),
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
            Positioned(
              top: 560,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  _currentLocation();
                },
                child: Container(
                  width: screenWidth * (40 / 360),
                  height: screenWidth * (40 / 360),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * (6 / 360)),
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}
