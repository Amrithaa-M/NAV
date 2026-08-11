import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import 'dart:async';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Position>? _positionStreamSubscription;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Fetches the current location once.
  Future<void> fetchCurrentLocation() async {
    _setLoading(true);
    _setError(null);
    try {
      _currentPosition = await _locationService.getCurrentPosition();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  /// Starts listening to continuous location updates.
  void startTracking() {
    _setError(null);
    try {
      _positionStreamSubscription = _locationService.getLocationStream().listen(
        (Position position) {
          _currentPosition = position;
          notifyListeners();
        },
        onError: (error) {
          _setError(error.toString().replaceAll('Exception: ', ''));
        }
      );
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Stops listening to location updates.
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
