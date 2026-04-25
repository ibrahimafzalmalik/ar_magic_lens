import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'services/ar_service.dart';
import 'models/bounding_box.dart';
import '3_scan_screen.dart'; // Import existing scan screen for 2D mode
import '4_track_progress_screen.dart';

/// Enhanced Scan Screen with AR capabilities
/// Supports both 2D (original) and AR modes
class ARScanScreen extends StatefulWidget {
  @override
  State<ARScanScreen> createState() => _ARScanScreenState();
}

class _ARScanScreenState extends State<ARScanScreen> {
  late ARService arService;
  bool isARMode = false; // Start with 2D mode, user can toggle.
  bool isARInitialized = false;
  String? lastDetectedObject;
  String? _pendingPlacementObject;
  DateTime _lastPlacementTime = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _detectionPollTimer;
  String? arStatusMessage = '2D mode active';

  // Keep reference to existing scan controller for 2D mode
  ScanController? scanController;

  @override
  void initState() {
    super.initState();
    arService = ARService();
    _detectionPollTimer = Timer.periodic(
      const Duration(milliseconds: 600),
      (_) => _captureLatestDetection(),
    );

    // Listen to AR object placement events
    arService.onObjectPlaced.listen((objectName) {
      if (mounted) {
        setState(() {
          arStatusMessage = 'Placed: ${_pendingPlacementObject ?? objectName}';
        });
      }
    });
  }

  @override
  void dispose() {
    _detectionPollTimer?.cancel();
    arService.dispose();
    if (scanController != null) {
      scanController!.stopCamera();
    }
    super.dispose();
  }

  /// Handle AR view creation
  void _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arService
        .initializeAR(
      sessionManager: sessionManager,
      objectManager: objectManager,
      anchorManager: anchorManager,
    )
        .then((_) {
      sessionManager.onPlaneOrPointTap = _onPlaneTap;
      if (mounted) {
        setState(() {
          isARInitialized = true;
          arStatusMessage = 'AR Ready - detect in 2D, then tap plane';
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          arStatusMessage = 'AR Error: $error';
          isARInitialized = false;
        });
      }
    });
  }

  /// Handle plane tap (for manual object placement)
  void _onPlaneTap(List<ARHitTestResult> hits) {
    if (hits.isEmpty || _pendingPlacementObject == null) return;
    final now = DateTime.now();
    if (now.difference(_lastPlacementTime).inMilliseconds < 1200) return;

    try {
      _lastPlacementTime = now;
      final hit = hits.first;
      final objectName =
          '${_pendingPlacementObject!}_${DateTime.now().millisecondsSinceEpoch}';
      arService.placeModelAtHit(
        hitTestResult: hit,
        objectName: objectName,
      );
      setState(() {
        arStatusMessage = 'Placed $_pendingPlacementObject. Tap plane to add more.';
      });
    } catch (e) {
      print('Error handling plane tap: $e');
    }
  }

  /// Place object at detected location (from TensorFlow Lite)
  /// This is called when an object is detected in 2D mode and user wants to place it in AR
  Future<void> placeObjectAtDetection(BoundingBox box) async {
    if (!isARMode || !isARInitialized) return;
    if (_pendingPlacementObject == box.label) return;
    setState(() {
      lastDetectedObject = box.label;
      _pendingPlacementObject = box.label;
      arStatusMessage = 'Ready: ${box.label}. Tap a plane to place it.';
    });
    TrackProgressData.addDetectedObjects([box.label]);
  }

  void _captureLatestDetection() {
    if (!mounted || isARMode || scanController == null) return;
    final latestBox = scanController!.getLatestDetection();
    if (latestBox == null || latestBox.label == lastDetectedObject) return;
    setState(() {
      lastDetectedObject = latestBox.label;
      arStatusMessage = 'Detected in 2D: ${latestBox.label}';
    });
  }

  /// Handle object detection from 2D mode and place in AR when switching modes
  void _handleObjectDetectionForAR() {
    if (!isARMode) return;

    // If camera was stopped for AR, use the latest known detection label.
    if (lastDetectedObject != null) {
      // Small delay to ensure AR is ready
      Future.delayed(Duration(milliseconds: 500), () {
        if (!mounted || !isARInitialized || lastDetectedObject == null) return;
        setState(() {
          _pendingPlacementObject = lastDetectedObject;
          arStatusMessage = 'Ready: $lastDetectedObject. Tap a plane to place it.';
        });
      });
    }
  }

  /// Toggle between AR and 2D mode
  void _toggleARMode(bool value) {
    setState(() {
      isARMode = value;
      if (value) {
        arStatusMessage = 'Switching to AR mode...';
        _pendingPlacementObject = null;
        // Stop 2D camera when switching to AR
        if (scanController != null) {
          scanController!.stopCamera();
        }
        // Try to place detected objects in AR after a delay
        Future.delayed(Duration(seconds: 1), () {
          _handleObjectDetectionForAR();
        });
      } else {
        arService.removeAllObjects();
        arStatusMessage = 'Switched to 2D mode';
        _pendingPlacementObject = null;
        // Restart 2D camera when switching back
        if (scanController != null &&
            !scanController!.isCameraInitialized.value) {
          scanController!.initCamera();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Main content - AR or 2D camera view
            _buildMainView(),

            // UI Overlay
            _buildUIOverlay(),
          ],
        ),
      ),
    );
  }

  /// Build main view (AR or 2D camera)
  Widget _buildMainView() {
    if (isARMode) {
      return ARView(
        onARViewCreated: _onARViewCreated,
        planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
      );
    } else {
      // 2D Mode - Use existing scan screen implementation.
      return _build2DCameraView();
    }
  }

  /// Build 2D camera view (existing implementation)
  Widget _build2DCameraView() {
    return GetBuilder<ScanController>(
      init: ScanController(),
      builder: (controller) {
        scanController = controller;

        if (controller.isCameraInitialized.value &&
            controller.cameraController.value.isInitialized) {
          return Stack(
            children: [
              // Camera preview
              ClipRRect(
                borderRadius: BorderRadius.circular(50.r),
                child: Container(
                  width: double.infinity,
                  height: 550.h,
                  margin: EdgeInsets.only(top: 50.h),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TrackScreen()),
                      );
                    },
                    child: CameraPreview(controller.cameraController),
                  ),
                ),
              ),

              // Bounding boxes overlay
              Obx(() {
                return Stack(
                  children: controller.boundingBoxes.map((BoundingBox box) {
                    double x = box.x * ScreenUtil().screenWidth;
                    double y = box.y * ScreenUtil().screenHeight;
                    double w = box.width * ScreenUtil().screenWidth;
                    double h = box.height * ScreenUtil().screenHeight;

                    return Positioned(
                      left: x,
                      top: y + 50.h, // Account for top margin
                      width: w,
                      height: h,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 2.0),
                        ),
                        child: Text(
                          '${box.label}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            backgroundColor: Colors.white,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  /// Build UI overlay (controls and info)
  Widget _buildUIOverlay() {
    return Column(
      children: [
        // Top bar
        SafeArea(
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50.h, left: 30.w),
                height: 120.h,
                width: 120.w,
                child: Image.asset('assets/images/scan.png'),
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.only(top: 50.h, right: 30.w),
                child: InkWell(
                  onTap: () {
                    if (scanController != null) {
                      scanController!.stopCamera();
                    }
                    arService.dispose();
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/images/btn_back.png'),
                ),
              ),
            ],
          ),
        ),

        Spacer(),

        // AR Mode Toggle
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isARMode ? 'AR Mode' : '2D Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    arStatusMessage ?? '',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              Switch(
                value: isARMode,
                onChanged: _toggleARMode,
                activeColor: Colors.green,
              ),
            ],
          ),
        ),

        // Detection info
        if (isARMode && lastDetectedObject != null)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Detected: $lastDetectedObject',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Bottom instruction
        Container(
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Text(
            isARMode
                ? 'Point camera at surfaces. Objects will appear in AR space.'
                : 'Point camera at objects to detect them.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
