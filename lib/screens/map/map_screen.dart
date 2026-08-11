import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/map_provider.dart';
import '../../models/place_model.dart';
import '../../core/constants/colors.dart';

class MapScreen extends StatefulWidget {
  final Place? targetPlace;

  const MapScreen({super.key, this.targetPlace});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Clear any previous routes when opening the map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().clearRoute();
      _buildMarkers();
    });
  }

  void _buildMarkers() {
    final places = context.read<MapProvider>().places;
    final newMarkers = <Marker>{};

    for (var place in places) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.category,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.targetPlace?.id == place.id 
                ? BitmapDescriptor.hueRed 
                : BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // If we have a target place, animate the camera to it
    if (widget.targetPlace != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(widget.targetPlace!.latitude, widget.targetPlace!.longitude),
            zoom: 17.0,
          ),
        ),
      );
    }
  }

  void _getDirections() async {
    final locationProvider = context.read<LocationProvider>();
    final mapProvider = context.read<MapProvider>();

    if (locationProvider.currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for GPS location...')),
      );
      return;
    }

    if (widget.targetPlace == null) return;

    final origin = LatLng(
      locationProvider.currentPosition!.latitude, 
      locationProvider.currentPosition!.longitude
    );

    // Fetch and draw route
    await mapProvider.drawRoute(origin, widget.targetPlace!);

    if (mapProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mapProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Adjust camera to show both points
      _fitRouteToCamera(origin, LatLng(widget.targetPlace!.latitude, widget.targetPlace!.longitude));
    }
  }

  void _fitRouteToCamera(LatLng origin, LatLng destination) {
    if (_mapController == null) return;

    LatLngBounds bounds;
    if (origin.latitude > destination.latitude && origin.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: origin);
    } else if (origin.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(origin.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, origin.longitude));
    } else if (origin.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, origin.longitude),
          northeast: LatLng(origin.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: origin, northeast: destination);
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100), // 100 is the padding
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final mapProvider = context.watch<MapProvider>();
    
    // Default fallback position if everything fails
    final defaultPosition = const LatLng(37.4220, -122.0840);
    
    // Determine the initial camera position
    LatLng initialPosition = defaultPosition;
    if (widget.targetPlace != null) {
      initialPosition = LatLng(widget.targetPlace!.latitude, widget.targetPlace!.longitude);
    } else if (locationProvider.currentPosition != null) {
      initialPosition = LatLng(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.targetPlace?.name ?? 'Campus Map'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 16.0,
            ),
            markers: _markers,
            polylines: mapProvider.polylines,
            myLocationEnabled: locationProvider.currentPosition != null,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          
          if (widget.targetPlace != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.place, color: AppColors.terracotta, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.targetPlace!.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              widget.targetPlace!.category,
                              style: const TextStyle(
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: mapProvider.isRouting ? null : _getDirections,
                        icon: mapProvider.isRouting 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)
                              )
                            : const Icon(Icons.directions, color: AppColors.primary),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.highlightLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: widget.targetPlace == null 
        ? null 
        : FloatingActionButton(
            backgroundColor: AppColors.background,
            onPressed: () {
              if (locationProvider.currentPosition != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        locationProvider.currentPosition!.latitude,
                        locationProvider.currentPosition!.longitude,
                      ),
                      zoom: 17.0,
                    ),
                  ),
                );
              }
            },
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
    );
  }
}
