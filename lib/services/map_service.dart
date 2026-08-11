import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav/env/env.dart';

class MapService {
  // IMPORTANT: For a production app, do not hardcode your API key here.
  // Use flutter_dotenv or similar to keep it secure.
  static const String _googleMapsApiKey = Env.googleMapsApiKey;

  final PolylinePoints _polylinePoints = PolylinePoints(apiKey: _googleMapsApiKey);

  /// Calculates the route between the origin and destination using the Google Directions API.
  Future<List<LatLng>> getRouteCoordinates(LatLng origin, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];

    try {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.walking, // Campus navigation should default to walking
        ),
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        throw Exception(result.errorMessage ?? 'Failed to find route');
      }
    } catch (e) {
      throw Exception('Routing error: $e');
    }

    return polylineCoordinates;
  }
}