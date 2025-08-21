import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:io';
import '3_scan_screen.dart';
import '4_track_progress_screen.dart';
import '5_parental_control_screen.dart';
import 'main.dart';
import 'package:firebase_storage/firebase_storage.dart';


class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  final GlobalKey _pickImageKey = GlobalKey();
  final GlobalKey _logOutKey = GlobalKey();
  final GlobalKey _scanObjectsKey = GlobalKey();
  final GlobalKey _trackProgressKey = GlobalKey();
  final GlobalKey _parentalControlKey = GlobalKey();
  final GlobalKey _takeTourKey = GlobalKey();

  User? _currentUser;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([
        _pickImageKey,
        _logOutKey,
        _scanObjectsKey,
        _trackProgressKey,
        _parentalControlKey,
        _takeTourKey
      ]);
    });
  }

  void _loadCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadProfilePicture(_imageFile!);
    }
  }

  Future<void> _uploadProfilePicture(File image) async {

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('profile_pics').child('${_currentUser!.uid}.jpg');
      await storageRef.putFile(image);
      final photoURL = await storageRef.getDownloadURL();

      // Update user's profile
      await _currentUser!.updatePhotoURL(photoURL);
      _loadCurrentUser(); // Refresh the user details
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error uploading profile picture: $e"),
        ),
      );
      print('Error uploading profile picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.sh,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: ShowCaseWidget(
        builder: (BuildContext context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(120.r)
                      ),
                      margin: EdgeInsets.only(top: 70.h, left: 20.w),
                      width: 120.w,
                      height: 120.h,
                      child: Showcase(
                        overlayOpacity: 0.3,
                        onTargetDoubleTap: (){
                          ShowCaseWidget.of(context).dismiss();
                        },
                        title: "Profile Picture",
                        targetBorderRadius: BorderRadius.circular(120.r),
                        key: _pickImageKey,
                        description: 'Tap here to upload your profile picture',
                        child: InkWell(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundImage: _currentUser != null && _currentUser!.photoURL != null
                                ? NetworkImage(_currentUser!.photoURL!)
                                : AssetImage('assets/images/avatar.png') as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      margin: EdgeInsets.only(top: 70.h, right: 30.w),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await GoogleSignIn().signOut();
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context, MaterialPageRoute(builder: (context) => LogIn()));
                          print('You Pressed Log Out Button');
                        },
                        child: Showcase(
                            overlayOpacity: 0.3,
                            onTargetDoubleTap: (){
                              ShowCaseWidget.of(context).dismiss();
                            },
                            title: "Log Out",
                          targetBorderRadius: BorderRadius.circular(50.r),
                            key: _logOutKey,
                            description: 'Tap here to log out',
                            child: Image.asset('assets/images/btn_logout.png')
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20.h, left: 20.w),
                      child: Text(
                        'Hello!',
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20.w),
                      child: Text(
                        _currentUser != null && _currentUser!.displayName != null
                            ? _currentUser!.displayName!
                            : 'User',
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(30.r),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ScanScreen()));
                        print('You Tapped Scan Objects');
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30.r),
                              color: Colors.white,
                            ),
                            margin: EdgeInsets.only(top: 50.h, left: 40.w),
                            width: 150.w,
                            height: 180.h,
                            child: Showcase(
                              overlayOpacity: 0.3,
                              onTargetDoubleTap: (){
                                ShowCaseWidget.of(context).dismiss();
                              },
                              title: "Scan Objects",
                              targetBorderRadius: BorderRadius.circular(30.r),
                              key: _scanObjectsKey,
                              description: 'Tap here to scan objects',
                              child: Column(
                                children: [
                                  Container(
                                    child: Image.asset('assets/images/scan.png', height: 130.h, width: 130.w),
                                  ),
                                  Container(
                                    child: Text('Scan Objects', style: TextStyle(fontSize: 16.sp)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(30.r),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TrackScreen()));
                        print('You Tapped Track Progress');
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30.r),
                              color: Colors.white,
                            ),
                            margin: EdgeInsets.only(top: 50.h, right: 40.w),
                            width: 150.w,
                            height: 180.h,
                            child: Showcase(
                              overlayOpacity: 0.3,
                              onTargetDoubleTap: (){
                                ShowCaseWidget.of(context).dismiss();
                              },
                              title: "Track Progress",
                              targetBorderRadius: BorderRadius.circular(30.r),
                              key: _trackProgressKey,
                              description: 'Tap here to track your progress',
                              child: Column(
                                children: [
                                  Container(
                                    child: Image.asset('assets/images/track.png', height: 130.h, width: 130.w),
                                  ),
                                  Container(
                                    child: Text('Track Progress', style: TextStyle(fontSize: 16.sp)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(30.r),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ParentScreen()));
                        print('You Tapped Parental Control');
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30.r),
                              color: Colors.white,
                            ),
                            margin: EdgeInsets.only(top: 50.h, left: 40.w),
                            width: 150.w,
                            height: 180.h,
                            child: Showcase(
                              overlayOpacity: 0.3,
                              onTargetDoubleTap: (){
                                ShowCaseWidget.of(context).dismiss();
                              },
                              title: "Parental Control",
                              targetBorderRadius: BorderRadius.circular(30.r),
                              key: _parentalControlKey,
                              description: 'Tap here to access parental controls',
                              child: Column(
                                children: [
                                  Container(
                                    child: Image.asset('assets/images/parent.png', height: 130.h, width: 130.w),
                                  ),
                                  Container(
                                    child: Text('Parental Control', style: TextStyle(fontSize: 16.sp)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(30.r),
                      onTap: () {
                        ShowCaseWidget.of(context).startShowCase([_pickImageKey, _logOutKey, _scanObjectsKey, _trackProgressKey, _parentalControlKey, _takeTourKey]);
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30.r),
                              color: Colors.white,
                            ),
                            margin: EdgeInsets.only(top: 50.h, right: 40.w),
                            width: 150.w,
                            height: 180.h,
                            child: Showcase(
                              overlayOpacity: 0.3,
                              onTargetDoubleTap: (){
                                ShowCaseWidget.of(context).dismiss();
                              },
                              title: "Take Tour",
                              targetBorderRadius: BorderRadius.circular(30.r),
                              key: _takeTourKey,
                              description: 'Tap here to Take a Tour',
                              child: Column(
                                children: [
                                  Container(
                                    child: Image.asset('assets/images/tour.png', width: 130.w, height: 130.h),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 0.w),
                                    child: Text('Take A Tour', style: TextStyle(fontSize: 16.sp)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
