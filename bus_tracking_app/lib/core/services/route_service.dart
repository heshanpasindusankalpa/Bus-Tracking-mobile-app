import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_tracking_app/models/route.dart' as app_route;

/// Service for managing routes in Firebase Firestore
class RouteService {
  static final RouteService _instance = RouteService._internal();
  factory RouteService() => _instance;
  RouteService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _routesCollection => _firestore.collection('routes');

  // ========== CREATE ROUTE ==========

  /// Create a new route in Firebase
  /// Returns the route ID if successful
  Future<String> createRoute(app_route.Route route) async {
    try {
      final docRef = await _routesCollection.add(route.toMap());
      print('✅ Route created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating route: $e');
      throw Exception('Failed to create route: $e');
    }
  }

  // ========== READ ROUTES ==========

  /// Get a single route by ID
  Future<app_route.Route?> getRoute(String routeId) async {
    try {
      final doc = await _routesCollection.doc(routeId).get();
      if (!doc.exists) {
        print('⚠️ Route with ID $routeId not found');
        return null;
      }
      return app_route.Route.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      print('❌ Error fetching route: $e');
      throw Exception('Failed to get route: $e');
    }
  }

  /// Get all routes
  Future<List<app_route.Route>> getAllRoutes() async {
    try {
      final querySnapshot = await _routesCollection.get();
      final routes = querySnapshot.docs
          .map(
            (doc) => app_route.Route.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
      print('✅ Fetched ${routes.length} routes from Firebase');
      return routes;
    } catch (e) {
      print('❌ Error fetching all routes: $e');
      throw Exception('Failed to get routes: $e');
    }
  }

  /// Get active routes only
  Future<List<app_route.Route>> getActiveRoutes() async {
    try {
      final querySnapshot =
          await _routesCollection.where('isActive', isEqualTo: true).get();
      final routes = querySnapshot.docs
          .map(
            (doc) => app_route.Route.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
      print('✅ Fetched ${routes.length} active routes');
      return routes;
    } catch (e) {
      print('❌ Error fetching active routes: $e');
      throw Exception('Failed to get active routes: $e');
    }
  }

  /// Search routes by route number
  Future<app_route.Route?> searchByRouteNumber(String routeNumber) async {
    try {
      final querySnapshot = await _routesCollection
          .where('routeNumber', isEqualTo: routeNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ Route with number $routeNumber not found');
        return null;
      }

      return app_route.Route.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>,
        querySnapshot.docs.first.id,
      );
    } catch (e) {
      print('❌ Error searching route by number: $e');
      throw Exception('Failed to search route: $e');
    }
  }

  // ========== UPDATE ROUTE ==========

  /// Update specific fields of a route
  Future<void> updateRoute(
    String routeId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _routesCollection.doc(routeId).update(updates);
      print('✅ Route $routeId updated successfully');
    } catch (e) {
      print('❌ Error updating route: $e');
      throw Exception('Failed to update route: $e');
    }
  }

  /// Update entire route object
  Future<void> updateRouteObject(
    String routeId,
    app_route.Route route,
  ) async {
    try {
      await _routesCollection.doc(routeId).set(route.toMap());
      print('✅ Route $routeId updated successfully');
    } catch (e) {
      print('❌ Error updating route object: $e');
      throw Exception('Failed to update route: $e');
    }
  }

  /// Toggle route active status
  Future<void> toggleRouteStatus(String routeId, bool isActive) async {
    try {
      await _routesCollection.doc(routeId).update({'isActive': isActive});
      print('✅ Route $routeId status updated to: $isActive');
    } catch (e) {
      print('❌ Error toggling route status: $e');
      throw Exception('Failed to toggle route status: $e');
    }
  }

  /// Add stop to route's stopIds list
  Future<void> addStopToRoute(String routeId, String stopId) async {
    try {
      await _routesCollection.doc(routeId).update({
        'stopIds': FieldValue.arrayUnion([stopId])
      });
      print('✅ Stop $stopId added to route $routeId');
    } catch (e) {
      print('❌ Error adding stop to route: $e');
      throw Exception('Failed to add stop to route: $e');
    }
  }

  /// Remove stop from route's stopIds list
  Future<void> removeStopFromRoute(String routeId, String stopId) async {
    try {
      await _routesCollection.doc(routeId).update({
        'stopIds': FieldValue.arrayRemove([stopId])
      });
      print('✅ Stop $stopId removed from route $routeId');
    } catch (e) {
      print('❌ Error removing stop from route: $e');
      throw Exception('Failed to remove stop from route: $e');
    }
  }

  // ========== DELETE ROUTE ==========

  /// Delete a route
  Future<void> deleteRoute(String routeId) async {
    try {
      await _routesCollection.doc(routeId).delete();
      print('✅ Route $routeId deleted successfully');
    } catch (e) {
      print('❌ Error deleting route: $e');
      throw Exception('Failed to delete route: $e');
    }
  }

  // ========== REAL-TIME LISTENERS ==========

  /// Listen to all routes in real-time
  Stream<List<app_route.Route>> getAllRoutesStream() {
    return _routesCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => app_route.Route.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  /// Listen to active routes in real-time
  Stream<List<app_route.Route>> getActiveRoutesStream() {
    return _routesCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => app_route.Route.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  /// Listen to a single route in real-time
  Stream<app_route.Route?> getRouteStream(String routeId) {
    return _routesCollection.doc(routeId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return app_route.Route.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    });
  }
}
