import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all places from the 'places' collection in Firestore
  Future<List<Place>> getPlaces() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('places').get();
      return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load places: $e');
    }
  }

  /// Optional: Helper method to seed some initial data for testing
  /// In a real scenario, you'd add this from a Firebase admin panel
  Future<void> seedInitialPlaces() async {
    final placesCollection = _firestore.collection('places');
    
    final existing = await placesCollection.limit(1).get();
    if (existing.docs.isNotEmpty) return; // Already seeded

    final List<Map<String, dynamic>> dummyPlaces = [
      {
        'name': 'Central Library',
        'category': 'Academic',
        'latitude': 37.4220, // using default emulator coords for demo
        'longitude': -122.0840,
      },
      {
        'name': 'Main Cafeteria',
        'category': 'Food',
        'latitude': 37.4225,
        'longitude': -122.0845,
      },
      {
        'name': 'Science Labs',
        'category': 'Academic',
        'latitude': 37.4215,
        'longitude': -122.0835,
      },
      {
        'name': 'Grand Auditorium',
        'category': 'Event',
        'latitude': 37.4210,
        'longitude': -122.0850,
      }
    ];

    for (var place in dummyPlaces) {
      await placesCollection.add(place);
    }
  }
}
