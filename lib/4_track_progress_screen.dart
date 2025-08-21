import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '3_scan_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class TrackScreen extends StatefulWidget {
  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {

  final FlutterTts flutterTts = FlutterTts();
  Timer? _timer;

  Future<void> _speak(String word) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(10.0);
    await flutterTts.speak(word);
  }

  static final RxList<String> _detectedObjects = <String>[].obs;

  static void clearAllObjects() {
    _detectedObjects.clear();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      DateTime now = DateTime.now();
      if (now.hour == 0 && now.minute == 0) {
        clearAllObjects();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Mapping detected objects to their corresponding images
  Map<String, String> objectImages = {
    "Person": "assets/images/person.png",
    "Bicycle": "assets/images/bicycle.png",
    "Car": "assets/images/car.png",
    "Motorcycle": "assets/images/motorcycle.png",
    "Airplane": "assets/images/airplane.png",
    "Bus": "assets/images/bus.png",
    "Train": "assets/images/train.png",
    "Truck": "assets/images/truck.png",
    "Boat": "assets/images/boat.png",
    "Traffic Light": "assets/images/traffic_light.png",
    "Fire Hydrant": "assets/images/fire_hydrant.png",
    "Stop Sign": "assets/images/stop_sign.png",
    "Parking Meter": "assets/images/parking_meter.png",
    "Bench": "assets/images/bench.png",
    "Bird": "assets/images/bird.png",
    "Cat": "assets/images/cat.png",
    "Dog": "assets/images/dog.png",
    "Horse": "assets/images/horse.png",
    "Sheep": "assets/images/sheep.png",
    "Cow": "assets/images/cow.png",
    "Elephant": "assets/images/elephant.png",
    "Bear": "assets/images/bear.png",
    "Zebra": "assets/images/zebra.png",
    "Giraffe": "assets/images/giraffe.png",
    "Backpack": "assets/images/backpack.png",
    "Umbrella": "assets/images/umbrella.png",
    "Handbag": "assets/images/handbag.png",
    "Tie": "assets/images/tie.png",
    "Suitcase": "assets/images/suitcase.png",
    "Frisbee": "assets/images/frisbee.png",
    "Skis": "assets/images/skis.png",
    "Snowboard": "assets/images/snowboard.png",
    "Sports Ball": "assets/images/sports_ball.png",
    "Kite": "assets/images/kite.png",
    "Baseball Bat": "assets/images/baseball_bat.png",
    "Baseball Glove": "assets/images/baseball_glove.png",
    "Skateboard": "assets/images/skateboard.png",
    "Surfboard": "assets/images/surfboard.png",
    "Tennis Racket": "assets/images/tennis racket.png",
    "Bottle": "assets/images/bottle.png",
    "Wine Glass": "assets/images/wine glass.png",
    "Cup": "assets/images/cup.png",
    "Fork": "assets/images/fork.png",
    "Knife": "assets/images/knife.png",
    "Spoon": "assets/images/spoon.png",
    "Bowl": "assets/images/bowl.png",
    "Banana": "assets/images/banana.png",
    "Apple": "assets/images/apple.png",
    "Sandwich": "assets/images/sandwich.png",
    "Orange": "assets/images/orange.png",
    "Broccoli": "assets/images/broccoli.png",
    "Carrot": "assets/images/carrot.png",
    "Hot Dog": "assets/images/hot_dog.png",
    "Pizza": "assets/images/pizza.png",
    "Donut": "assets/images/donut.png",
    "Cake": "assets/images/cake.png",
    "Chair": "assets/images/chair.png",
    "Couch": "assets/images/couch.png",
    "Potted plant": "assets/images/potted_plant.png",
    "Bed": "assets/images/bed.png",
    "Dining Table": "assets/images/dinning_table.png",
    "Toilet": "assets/images/toilet.png",
    "Tv": "assets/images/tv.png",
    "Laptop": "assets/images/laptop.png",
    "Mouse": "assets/images/mouse.png",
    "Remote": "assets/images/remote.png",
    "Keyboard": "assets/images/keyboard.png",
    "Cell phone": "assets/images/cell_phone.png",
    "Microwave": "assets/images/microwave.png",
    "Oven": "assets/images/oven.png",
    "Toaster": "assets/images/toaster.png",
    "Sink": "assets/images/sink.png",
    "Refrigerator": "assets/images/refrigerator.png",
    "Book": "assets/images/book.png",
    "Clock": "assets/images/clock.png",
    "Vase": "assets/images/vase.png",
    "Scissors": "assets/images/scissors.png",
    "Teddy Bear": "assets/images/teddy_bear.png",
    "Hair Drier": "assets/images/hair_drier.png",
    "Toothbrush": "assets/images/toothbrush.png",
    // Add the rest of your mappings here
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 150.w,
                  margin: EdgeInsets.only(top: 40.h, left: 20.w),
                  child: Image.asset('assets/images/trackimg.png'),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 50.h),
                      width: 241.w,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.h, left: 80.w),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset('assets/images/btn_back.png'),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                margin: EdgeInsets.only(top: 30.h),
                height: 500.h,
                width: 410.w,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 10.w, top: 10.h),
                      child: Text(
                        "Today You have Learned",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.h),
                      height: 425.h,
                      width: 410.w,
                      child: Obx(() {
                        var detectedObjects = TrackProgressData.getDetectedObjects();
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: objectImages.containsKey(detectedObjects[index])
                                  ? Image.asset(objectImages[detectedObjects[index]]!, height: 40.h)
                                  : SizedBox.shrink(),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      detectedObjects[index],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),

                              InkWell(
                                  onTap: () => _speak(detectedObjects[index]),
                                  child: Container(
                                      child: Image.asset('assets/images/pron.png',height: 50.h)
                                  ),
                                ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.black,),
                                onPressed: () {
                                  TrackProgressData.deleteObject(detectedObjects[index]);
                                },
                              ),
                            );
                          },

                          itemCount: detectedObjects.length,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 160.h,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 50.w, top: 20.h),
                    child: Text(
                      'Todays Learning',
                      style: TextStyle(fontSize: 20.sp, fontStyle: FontStyle.italic),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30.w),
                    width: 20.w,
                  ),
                  Image.asset('assets/images/books.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}