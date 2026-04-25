import 'dart:async';
import 'dart:io';

import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARService {
  /// Upper bound on simultaneous anchors/nodes to limit memory and GPU load.
  static const int maxPlacedObjects = 12;

  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  bool isARInitialized = false;
  bool isPlaneDetectionEnabled = false;

  final Map<String, ARPlaneAnchor> placedAnchors = {};
  final Map<String, ARNode> placedNodes = {};
  final List<String> _placementOrder = [];
  bool _streamsClosed = false;

  final StreamController<String> _onObjectPlacedController =
      StreamController<String>.broadcast();
  final StreamController<String> _onObjectRemovedController =
      StreamController<String>.broadcast();

  Stream<String> get onObjectPlaced => _onObjectPlacedController.stream;
  Stream<String> get onObjectRemoved => _onObjectRemovedController.stream;

  Future<void> initializeAR({
    required ARSessionManager sessionManager,
    required ARObjectManager objectManager,
    required ARAnchorManager anchorManager,
  }) async {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    arSessionManager!.onInitialize(
      showAnimatedGuide: true,
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: true,
    );
    arObjectManager!.onInitialize();

    isARInitialized = true;
    isPlaneDetectionEnabled = true;
  }

  Future<void> placeModelAtHit({
    required ARHitTestResult hitTestResult,
    required String objectName,
    String? modelUrl,
    vector.Vector3? scale,
  }) async {
    if (!isARInitialized || arAnchorManager == null || arObjectManager == null) {
      return;
    }

    final anchor = ARPlaneAnchor(transformation: hitTestResult.worldTransform);
    final didAddAnchor = await arAnchorManager!.addAnchor(anchor) ?? false;
    if (!didAddAnchor) return;

    final node = ARNode(
      type: NodeType.webGLB,
      uri: modelUrl ??
          'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      scale: scale ?? vector.Vector3.all(0.2),
    );

    final didAddNode =
        await arObjectManager!.addNode(node, planeAnchor: anchor) ?? false;
    if (!didAddNode) {
      arAnchorManager!.removeAnchor(anchor);
      return;
    }

    placedAnchors[objectName] = anchor;
    placedNodes[objectName] = node;
    _placementOrder.add(objectName);

    while (placedNodes.length > maxPlacedObjects) {
      final oldest = _placementOrder.first;
      removeObject(oldest);
    }

    _onObjectPlacedController.add(objectName);
  }

  void removeObject(String objectName) {
    _placementOrder.remove(objectName);
    final node = placedNodes.remove(objectName);
    final anchor = placedAnchors.remove(objectName);

    if (node != null) {
      arObjectManager?.removeNode(node);
    }
    if (anchor != null) {
      arAnchorManager?.removeAnchor(anchor);
    }

    _onObjectRemovedController.add(objectName);
  }

  void removeAllObjects() {
    final objectNames = List<String>.from(placedNodes.keys);
    for (final name in objectNames) {
      removeObject(name);
    }
    _placementOrder.clear();
  }

  /// Stops AR session and clears scene, but keeps Dart-side streams usable
  /// so the same [ARService] can re-enter AR after toggling 2D/AR.
  void pauseARSession() {
    removeAllObjects();
    arSessionManager?.dispose();
    arSessionManager = null;
    arObjectManager = null;
    arAnchorManager = null;
    isARInitialized = false;
    isPlaneDetectionEnabled = false;
  }

  static Future<bool> isARSupported() async {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  void dispose() {
    pauseARSession();
    if (!_streamsClosed) {
      _onObjectPlacedController.close();
      _onObjectRemovedController.close();
      _streamsClosed = true;
    }
  }
}
