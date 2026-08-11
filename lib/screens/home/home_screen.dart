import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/map_provider.dart';
import '../../core/constants/colors.dart';
import '../auth/login_screen.dart';
import '../map/map_screen.dart';
import '../../models/place_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().startTracking();
      // Ensure we fetch the places when home screen loads
      context.read<MapProvider>().fetchPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final locationProvider = context.watch<LocationProvider>();
    final mapProvider = context.watch<MapProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NAV Campus'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              context.read<LocationProvider>().stopTracking();
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user?.displayName?.split(' ')[0] ?? "Explorer"}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Where would you like to go today?',
                    style: TextStyle(
                      color: AppColors.highlightLight.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar Placeholder
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: AppColors.secondary),
                        hintText: 'Search for classrooms, labs...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Location Status Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.highlightLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.highlightLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.my_location, color: AppColors.tertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (locationProvider.errorMessage != null)
                            Text(
                              locationProvider.errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            )
                          else if (locationProvider.currentPosition != null)
                            Text(
                              'Lat: ${locationProvider.currentPosition!.latitude.toStringAsFixed(4)}, '
                              'Lng: ${locationProvider.currentPosition!.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(color: AppColors.secondary, fontSize: 13),
                            )
                          else
                            const Text(
                              'Fetching GPS coordinates...',
                              style: TextStyle(color: AppColors.secondary, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Access Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Quick Access',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (mapProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (mapProvider.places.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No places found. Ensure your database is seeded.',
                  style: TextStyle(color: AppColors.secondary),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: mapProvider.places.length,
                  itemBuilder: (context, index) {
                    final place = mapProvider.places[index];
                    return _buildQuickAccessCard(context, place);
                  },
                ),
              ),
            const SizedBox(height: 32),
            // Floating button to open general map
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MapScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open Campus Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, Place place) {
    IconData icon;
    Color color;

    // Pick a dynamic icon based on category
    switch (place.category.toLowerCase()) {
      case 'academic':
        icon = Icons.local_library;
        color = AppColors.tertiary;
        break;
      case 'food':
        icon = Icons.restaurant;
        color = AppColors.warmRust;
        break;
      case 'event':
        icon = Icons.theater_comedy;
        color = AppColors.highlightMedium;
        break;
      default:
        icon = Icons.place;
        color = AppColors.primary;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MapScreen(targetPlace: place),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 30,
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                place.name,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
