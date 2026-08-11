import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/place_model.dart';
import '../services/database_service.dart';
import '../services/map_service.dart';
import '../core/constants/colors.dart';

class MapProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final MapService _mapService = MapService();

  List<Place> _places = [];
  Set<Polyline> _polylines = {};
  
  bool _isLoading = false;
  bool _isRouting = false;
  String? _errorMessage;

  List<Place> get places => _places;
  Set<Polyline> get polylines => _polylines;
  
  bool get isLoading => _isLoading;
  bool get isRouting => _isRouting;
  String? get errorMessage => _errorMessage;

  MapProvider() {
    _init();
  }

  Future<void> _init() async {
    await _databaseService.seedInitialPlaces();
    await fetchPlaces();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setRouting(bool value) {
    _isRouting = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchPlaces() async {
    _setLoading(true);
    _setError(null);
    try {
      _places = await _databaseService.getPlaces();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  /// Calculates a route between current location and destination, then draws a Polyline
  Future<void> drawRoute(LatLng origin, Place destination) async {
    _setRouting(true);
    _setError(null);
    try {
      final destLatLng = LatLng(destination.latitude, destination.longitude);
      final points = await _mapService.getRouteCoordinates(origin, destLatLng);
      
      final polylineId = PolylineId('route_${destination.id}');
      
      final polyline = Polyline(
        polylineId: polylineId,
        color: AppColors.primary,
        points: points,
        width: 5,
      );

      _polylines = {polyline};
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _polylines = {}; // Clear existing route on error
    } finally {
      _setRouting(false);
    }
  }

  /// Clears the currently active route from the map
  void clearRoute() {
    _polylines = {};
    notifyListeners();
  }
}
