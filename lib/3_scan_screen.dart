import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '4_track_progress_screen.dart';
import 'models/bounding_box.dart';
import 'package:get/get.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  @override
  State<ScanScreen> createState() => ScanScreenState();
}


class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    stopCamera();
    super.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var boundingBoxes = <BoundingBox>[].obs;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  var isInterpreterBusy = false.obs;

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
      );

      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            if (!isInterpreterBusy.value) {
              objectDetector(image);
            }
          }
          update();
        });
      });

      isCameraInitialized(true);
      update();
    } else {
      print('Permission denied');
    }
  }

  initTFLite() async {
    try {
      await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false,
      );
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  objectDetector(CameraImage image) async {
    isInterpreterBusy.value = true;

    try {
      var detector = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((e) {
          return e.bytes;
        }).toList(),
        model: "SSDMobileNet",
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResultsPerClass: 1,
        threshold: 0.4,
      );

      if (detector != null && detector.isNotEmpty) {
        boundingBoxes.value = detector.map((detectedObject) {
          var rect = detectedObject['rect'];
          if (rect != null) {
            double rectH = rect['h'];
            double rectW = rect['w'];
            double rectX = rect['x'];
            double rectY = rect['y'];

            return BoundingBox(
              x: rectX,
              y: rectY,
              width: rectW,
              height: rectH,
              label: detectedObject['detectedClass'],
              confidence: detectedObject['confidenceInClass'],
            );
          } else {
            return null;
          }
        }).where((box) => box != null).toList().cast<BoundingBox>();

        // Save detected objects to shared state
        TrackProgressData.addDetectedObjects(boundingBoxes.map((box) => box.label).toList());
      } else {
        print("No detections found or detector result is null");
      }
    } catch (e) {
      print('Error during object detection: $e');
    }

    isInterpreterBusy.value = false;
  }

  void stopCamera() {
    if (cameraController.value.isStreamingImages) {
      cameraController.stopImageStream();
    }
    if (cameraController.value.isInitialized) {
      cameraController.dispose();
    }
    isCameraInitialized.value = false;  // Ensure the value is updated when the camera is disposed
  }
}

class TrackProgressData {
  static RxList<String> detectedObjects = <String>[].obs;

  static void addDetectedObjects(List<String> objects) {
    detectedObjects.addAll(objects);
  }

  static RxList<String> getDetectedObjects() {
    return detectedObjects;
  }

  static void deleteObject(String object) {
    detectedObjects.remove(object);
  }
}


class ScanScreenState extends State<ScanScreen> {
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
        child: Column(
          children: [
            Row(
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
                      Get.find<ScanController>().stopCamera();
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/images/btn_back.png'),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 50.h),
              height: 550.h,
              width: 360.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.r),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    spreadRadius: 2,
                  )
                ],
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.r),
                child: GetBuilder<ScanController>(
                  init: ScanController(),
                  builder: (controller) {
                    if (controller.isCameraInitialized.value && controller.cameraController.value.isInitialized) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.r),
                            child: Container(
                              width: double.infinity,
                              height: 550.h,
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => TrackScreen()));
                                  print('You Tapped Track Progress');
                                },
                                  child: CameraPreview(controller.cameraController)
                              ),
                            ),
                          ),
                          Obx(() {
                            return Stack(
                              children: controller.boundingBoxes.map((BoundingBox box) {
                                double x = box.x * ScreenUtil().screenWidth;
                                double y = box.y * ScreenUtil().screenHeight;
                                double w = box.width * ScreenUtil().screenWidth;
                                double h = box.height * ScreenUtil().screenHeight;

                                return Positioned(
                                  left: x,
                                  top: y,
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
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
            Obx(() {
              var label = Get.find<ScanController>().boundingBoxes.isNotEmpty
                  ? Get.find<ScanController>().boundingBoxes.first.label
                  : "";
              return Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 50.h, left: 50.w),
                    child: Text(
                      'You have found ',
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 50.h),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}