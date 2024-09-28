import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:readygreen/widgets/map/locationbutton.dart';
import 'package:readygreen/widgets/map/destinationbar.dart';
import 'package:readygreen/api/map_api.dart';
import 'package:provider/provider.dart';
import 'package:readygreen/provider/current_location.dart';

class MapDirectionPage extends StatefulWidget {
  const MapDirectionPage({super.key});

  @override
  _MapDirectionPageState createState() => _MapDirectionPageState();
}

class _MapDirectionPageState extends State<MapDirectionPage> {
  late GoogleMapController mapController;
  final LatLng _center =
      const LatLng(36.354946759143, 127.29980994578); // 임시 좌표
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final loc.Location _location = loc.Location();
  final Set<Marker> _markers = {};
  final List<LatLng> _routeCoordinates = []; // 경로 좌표 리스트

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CurrentLocationProvider>(context, listen: false)
          .updateLocation();
      _fetchRouteData();
    });
  }

  // 경로 요청을 위한 함수
  Future<void> _fetchRouteData() async {
    final locationProvider =
        Provider.of<CurrentLocationProvider>(context, listen: false);

    if (locationProvider.currentPosition != null) {
      // 현재 위치 정보
      double startX = locationProvider.currentPosition!.longitude;
      double startY = locationProvider.currentPosition!.latitude;
      String startName =
          locationProvider.currentPlaceName ?? 'Unknown Start Location';

      // 도착지 정보 (임의의 값)
      double endX = 127.298412;
      double endY = 36.355443;
      String endName = "삼성화재 유성캠퍼스";

      // API 호출
      MapAPI mapAPI = MapAPI();
      var routeData = await mapAPI.fetchRoute(
        startX: startX,
        startY: startY,
        endX: endX,
        endY: endY,
        startName: startName,
        endName: endName,
        watch: true,
      );

      if (routeData != null) {
        // 경로 데이터를 바탕으로 coordinates 처리
        List<dynamic> features = routeData['routeDTO']['features'];
        List<LatLng> coordinates = [];

        for (var feature in features) {
          List<dynamic> points = feature['geometry']['coordinates'];
          for (var point in points) {
            coordinates.add(LatLng(point[1], point[0])); // 경도, 위도 순서로 추가
          }
        }

        setState(() {
          _routeCoordinates.addAll(coordinates);
        });
      }
    }
  }

  // 지도 생성 함수
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  // 위치 정보를 받아오는 함수
  Future<void> _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    loc.LocationData currentLocation = await _location.getLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 17.0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final locationProvider = Provider.of<CurrentLocationProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 17.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers,
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routeCoordinates, // 경로 좌표 리스트
                color: Colors.blue,
                width: 5,
              ),
            },
          ),
          Positioned(
            top: screenHeight * 0.8,
            right: screenWidth * 0.05,
            child: LocationButton(
              onTap: _currentLocation,
              screenWidth: screenWidth,
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: DestinationBar(
              currentLocation:
                  locationProvider.currentPlaceName ?? 'Loading...',
              destination: '삼성화재 유성캠퍼스',
            ),
          ),
        ],
      ),
    );
  }
}
