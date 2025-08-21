import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'main.dart';

class ParentScreen extends StatefulWidget {
  @override
  State<ParentScreen> createState() => ParentScreenState();
}

class ParentScreenState extends State<ParentScreen> {

  bool _toggle = false;
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  bool _hasNavigatedToLogin = false;


  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      _checkShutdownTime(now);
    });
  }

  void _checkShutdownTime(DateTime now) {
    if (_toggle && now.isAfter(_currentTime) && !_hasNavigatedToLogin) {
      _hasNavigatedToLogin = true;
      GoogleSignIn().signOut();
      FirebaseAuth.instance.signOut();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LogIn()),
              (Route<dynamic> route) => false,
        );
      });
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil with the current screen dimensions
    ScreenUtil.init(
      context,
      designSize: Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
    );

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
                  width: 120.w,
                  height: 120.h,
                  child: Image.asset('assets/images/parent.png'),
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(top: 70.h, right: 30.w),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      print('You Tapped Back Button');
                    },
                    child: Image.asset('assets/images/btn_back.png'),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(30.0.w),
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 30.h),
                    width: 450.w,
                    height: 464.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 3,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFF5FE9F2),
                              Color(0xFF37878C),
                            ],
                          ),
                        ),
                        margin: EdgeInsets.only(top: 50.h, left: 2.w),
                        width: 170.w,
                        height: 110.h,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 0.h),
                              width: 70.w,
                              height: 70.h,
                              child: Image.asset('assets/images/time.png'),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 0.h),
                              child: Text(
                                'Daily Limit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFF5FE9F2),
                          Color(0xFF37878C),
                        ],
                      ),
                    ),
                    margin: EdgeInsets.only(top: 50.h, left: 199.w),
                    width: 177.w,
                    height: 110.h,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 0.h),
                          width: 70.w,
                          height: 70.h,
                          child: Image.asset('assets/images/bed1.png'),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 0.h),
                          child: Text(
                            'Bed Time',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 170.h, left: 5.w),
                    width: 355.w,
                    height: 50.h,
                    color: Color(0xFFBFF8F8),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: 5.h, bottom: 4.h, left: 40.w, right: 130.w),
                          child: Text(
                            'Scheduled',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 35.w),
                          width: 50.w,
                          height: 30.h,
                          child: Switch(
                            activeTrackColor: Color(0xFF1DB1F2),
                            value: _toggle,
                            onChanged: (value) {
                              setState(() {

                                if (_currentTime.isBefore(DateTime.now())) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Time must be greater than Current Time"),
                                    ),
                                  );
                                } else {
                                  _toggle  = value;

                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 260.h, left: 25.w),
                        child: Container(
                          width: 120.w,
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 0.w),
                                child: Text(
                                  "${DateFormat('yMMMd').format(_currentTime)}",
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 0.w),
                                child: Text(
                                  "${DateFormat('EEEE').format(_currentTime)}",
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 0.w),
                                child: Text(
                                  "${DateFormat('jm').format(_currentTime)}",
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 260.h, left: 30.w),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Color(0xFF6E81C1),
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _currentTime =
                                          _currentTime.add(Duration(hours: 1));
                                    });
                                  },
                                ),
                                Text(
                                  ' Hour ',
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: Color(0xFF6E81C1),
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_currentTime
                                          .isBefore(DateTime.now())) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text("Time must be greater than Current Time"),
                                          ),
                                        );
                                      } else {
                                        _currentTime = _currentTime
                                            .subtract(Duration(hours: 1));
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Color(0xFF6E81C1),
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _currentTime = _currentTime
                                          .add(Duration(minutes: 1));
                                    });
                                  },
                                ),
                                Text(
                                  'Minute',
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: Color(0xFF6E81C1),
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_currentTime
                                          .isBefore(DateTime.now()) ||
                                          _currentTime.isAtSameMomentAs(
                                              DateTime.now())) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text("Time must be greater than Current Time"),
                                          ),
                                        );
                                      } else {
                                        _currentTime = _currentTime
                                            .subtract(Duration(minutes: 1));
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.h),
              child: Text(
                '"Everything in Excess is Bad"',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  fontSize: 19.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}