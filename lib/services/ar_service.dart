// AR package temporarily disabled due to compatibility issues
// import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/material.dart';
import 'dart:async';

/// AR Service for managing ARCore/ARKit sessions and object placement
/// Note: AR functionality temporarily disabled due to package compatibility issues
class ARService {
  // AR temporarily disabled
  // ArCoreController? arCoreController;
  dynamic arCoreController;
  bool isARInitialized = false;
  bool isPlaneDetectionEnabled = false;

  // Track placed objects
  // final Map<String, ArCoreNode> placedObjects = {};
  final Map<String, dynamic> placedObjects = {};

  // Stream controllers for AR events
  final StreamController<String> _onObjectPlacedController =
      StreamController<String>.broadcast();
  final StreamController<String> _onObjectRemovedController =
      StreamController<String>.broadcast();

  Stream<String> get onObjectPlaced => _onObjectPlacedController.stream;
  Stream<String> get onObjectRemoved => _onObjectRemovedController.stream;

  /// Initialize AR session
  Future<void> initializeAR(dynamic controller) async {
    try {
      arCoreController = controller;

      // Enable plane detection for surface tracking
      await enablePlaneDetection();

      // Set up AR session callbacks
      controller.onPlaneTap = _onPlaneTap;
      controller.onNodeTap = _onNodeTap;

      isARInitialized = true;
      print('AR Service initialized successfully');
    } catch (e) {
      print('Error initializing AR: $e');
      isARInitialized = false;
    }
  }

  /// Enable plane detection (horizontal and vertical surfaces)
  Future<void> enablePlaneDetection() async {
    if (arCoreController == null) return;

    try {
      // Try to enable plane detection - API may vary by package version
      final controller = arCoreController as dynamic;
      if (controller.enablePlaneDetection != null) {
        await controller.enablePlaneDetection();
      }
      isPlaneDetectionEnabled = true;
      print('Plane detection enabled');
    } catch (e) {
      // API not available in this package version - gracefully handle
      print('Plane detection not available in this package version: $e');
      isPlaneDetectionEnabled = false;
    }
  }

  /// Disable plane detection
  Future<void> disablePlaneDetection() async {
    if (arCoreController == null) return;

    try {
      // Try to disable plane detection - API may vary by package version
      final controller = arCoreController as dynamic;
      if (controller.disablePlaneDetection != null) {
        await controller.disablePlaneDetection();
      }
      isPlaneDetectionEnabled = false;
      print('Plane detection disabled');
    } catch (e) {
      // API not available - gracefully handle
      print('Plane detection disable not available: $e');
      isPlaneDetectionEnabled = false;
    }
  }

  /// Handle plane tap (for manual object placement)
  void _onPlaneTap(dynamic hits) {
    if (hits == null || (hits is List && hits.isEmpty)) return;
    try {
      final firstHit = hits is List ? hits.first : hits;
      final pose = firstHit?.pose;
      final translation = pose?.translation;
      print('Plane tapped at: $translation');
    } catch (e) {
      print('Plane tap handled: $e');
    }
  }

  /// Handle AR node tap (when user taps on placed object)
  void _onNodeTap(String name) {
    print('AR object tapped: $name');
    // You can emit events or trigger actions here
  }

  /// Place a 3D shape at hit test result
  Future<void> placeShapeAtHit({
    required dynamic hitTestResult,
    required String objectName,
    required dynamic shape,
    vector.Vector3? position,
    vector.Quaternion? rotation,
  }) async {
    if (arCoreController == null) return;

    try {
      // Remove existing object with same name if exists
      if (placedObjects.containsKey(objectName)) {
        removeObject(objectName);
      }

      // Use provided position/rotation or use hit test result
      vector.Vector3? pos = position;
      vector.Quaternion? rot = rotation;

      try {
        if (hitTestResult != null && hitTestResult.pose != null) {
          pos = position ?? (hitTestResult.pose.translation as vector.Vector3?);
          rot = rotation ?? (hitTestResult.pose.rotation as vector.Quaternion?);
        }
      } catch (e) {
        // API structure may differ - use provided values
      }

      if (pos == null) pos = vector.Vector3.zero();
      if (rot == null) rot = vector.Quaternion.identity();

      // Convert Quaternion to Vector4 for package API
      final rotVector4 = vector.Vector4(rot.x, rot.y, rot.z, rot.w);

      // Create node using dynamic API - AR temporarily disabled
      // final controller = arCoreController as dynamic;
      // final node = ArCoreNode(
      //   name: objectName,
      //   shape: shape,
      //   position: pos,
      //   rotation: rotVector4,
      // );
      //
      // if (controller.addArCoreNode != null) {
      //   controller.addArCoreNode(node);
      // }
      // placedObjects[objectName] = node;

      // AR disabled - just track in map
      placedObjects[objectName] = {'name': objectName, 'position': pos};

      _onObjectPlacedController.add(objectName);
      print('Placed AR object: $objectName at $pos');
    } catch (e) {
      print('Error placing AR object: $e');
    }
  }

  /// Place a 3D model at hit test result
  Future<void> placeModelAtHit({
    required dynamic hitTestResult,
    required String objectName,
    required String modelPath, // Path to .glb or .gltf file
    vector.Vector3? position,
    vector.Quaternion? rotation,
    vector.Vector3? scale,
  }) async {
    if (arCoreController == null) return;

    try {
      // Remove existing object with same name if exists
      if (placedObjects.containsKey(objectName)) {
        removeObject(objectName);
      }

      // Use provided position/rotation or use hit test result
      vector.Vector3? pos = position;
      vector.Quaternion? rot = rotation;

      try {
        if (hitTestResult != null && hitTestResult.pose != null) {
          pos = position ?? (hitTestResult.pose.translation as vector.Vector3?);
          rot = rotation ?? (hitTestResult.pose.rotation as vector.Quaternion?);
        }
      } catch (e) {
        // API structure may differ
      }

      if (pos == null) pos = vector.Vector3.zero();
      if (rot == null) rot = vector.Quaternion.identity();
      final scl = scale ?? vector.Vector3.all(1.0);

      // Convert Quaternion to Vector4 for package API
      final rotVector4 = vector.Vector4(rot.x, rot.y, rot.z, rot.w);

      // AR temporarily disabled
      // final node = ArCoreReferenceNode(
      //   name: objectName,
      //   objectUrl: modelPath,
      //   position: pos,
      //   rotation: rotVector4,
      //   scale: scl,
      // );
      //
      // final controller = arCoreController as dynamic;
      // if (controller.addArCoreNode != null) {
      //   controller.addArCoreNode(node);
      // }
      // placedObjects[objectName] = node;

      // AR disabled - just track in map
      placedObjects[objectName] = {
        'name': objectName,
        'position': pos,
        'modelPath': modelPath
      };

      _onObjectPlacedController.add(objectName);
      print('Placed AR model: $objectName at $pos');
    } catch (e) {
      print('Error placing AR model: $e');
    }
  }

  /// Place object at screen coordinates (converts 2D to 3D)
  Future<bool> placeObjectAtScreenPoint({
    required String objectName,
    required vector.Vector2 screenPoint,
    required dynamic shape,
  }) async {
    if (arCoreController == null) return false;

    try {
      // Perform hit test at screen point - API may vary
      final controller = arCoreController as dynamic;
      dynamic hits;

      if (controller.performHitTest != null) {
        hits = await controller.performHitTest(screenPoint);
      } else {
        // API not available - return false
        print('Hit test not available in this package version');
        return false;
      }

      if (hits == null || (hits is List && hits.isEmpty)) {
        print('No hit test result at screen point: $screenPoint');
        return false;
      }

      // Use first hit result
      final firstHit = hits is List ? hits.first : hits;
      await placeShapeAtHit(
        hitTestResult: firstHit,
        objectName: objectName,
        shape: shape,
      );

      return true;
    } catch (e) {
      print('Error placing object at screen point: $e');
      return false;
    }
  }

  /// Remove AR object by name
  void removeObject(String objectName) {
    // AR temporarily disabled
    // if (arCoreController == null) return;
    //
    // try {
    //   arCoreController!.removeNode(nodeName: objectName);
    //   placedObjects.remove(objectName);
    //   _onObjectRemovedController.add(objectName);
    //   print('Removed AR object: $objectName');
    // } catch (e) {
    //   print('Error removing AR object: $e');
    // }

    // Just remove from tracking
    placedObjects.remove(objectName);
    _onObjectRemovedController.add(objectName);
  }

  /// Remove all placed objects
  void removeAllObjects() {
    final objectNames = List<String>.from(placedObjects.keys);
    for (final name in objectNames) {
      removeObject(name);
    }
  }

  /// Get color for object type (for visual distinction)
  static int getColorForObject(String objectLabel) {
    final colorMap = {
      'Person': 0xFF2196F3, // Blue
      'Car': 0xFFF44336, // Red
      'Dog': 0xFF795548, // Brown
      'Cat': 0xFFFF9800, // Orange
      'Bird': 0xFF4CAF50, // Green
      'Bicycle': 0xFF9C27B0, // Purple
      'Motorcycle': 0xFF607D8B, // Blue Grey
      'Bus': 0xFFE91E63, // Pink
      'Truck': 0xFF3F51B5, // Indigo
      'Airplane': 0xFF00BCD4, // Cyan
    };

    return colorMap[objectLabel] ?? 0xFF4CAF50; // Default green
  }

  /// Create a colored sphere shape for an object
  /// Note: AR temporarily disabled - returns placeholder
  static dynamic createColoredSphere({
    required String objectLabel,
    double radius = 0.1,
  }) {
    // AR temporarily disabled
    return {'type': 'sphere', 'label': objectLabel, 'radius': radius};
  }

  /// Create a colored box shape for an object
  /// Note: AR temporarily disabled - returns placeholder
  static dynamic createColoredBox({
    required String objectLabel,
    vector.Vector3? size,
  }) {
    // AR temporarily disabled
    return {
      'type': 'box',
      'label': objectLabel,
      'size': size ?? vector.Vector3.all(0.2)
    };
  }

  /// Check if AR is supported on device
  static Future<bool> isARSupported() async {
    // ARCore/ARKit plugin should handle this
    // This is a placeholder - actual implementation depends on plugin
    return true;
  }

  /// Dispose AR session and clean up
  void dispose() {
    removeAllObjects();
    arCoreController?.dispose();
    arCoreController = null;
    isARInitialized = false;
    isPlaneDetectionEnabled = false;

    _onObjectPlacedController.close();
    _onObjectRemovedController.close();

    print('AR Service disposed');
  }
}
