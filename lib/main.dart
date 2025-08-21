import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '10_sign_up_screen.dart';
import '7_forgot_password_screen.dart';
import '2_home_screen.dart';
import 'global/common/toast.dart';
import 'package:magic_lens_03/0_splash_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDUtFhmslkCnElEsM28r56jgwcX3P19C04",
            appId: "1:266568489457:web:d933df4c6dc89b33dd0c50",
            messagingSenderId: "266568489457",
            projectId: "ar-magic-lens-bd20a",
            storageBucket: "gs://ar-magic-lens-bd20a.appspot.com"));
  }
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDUtFhmslkCnElEsM28r56jgwcX3P19C04",
          appId: "1:266568489457:web:d933df4c6dc89b33dd0c50",
          messagingSenderId: "266568489457",
          projectId: "ar-magic-lens-bd20a",
          storageBucket: "gs://ar-magic-lens-bd20a.appspot.com"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(430, 932),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Magic Lens',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => LogInState();
}

class LogInState extends State<LogIn> with SingleTickerProviderStateMixin {
  bool isSigning = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<Offset> _upperCloudAnimation;
  late Animation<Offset> _lowerCloudAnimation;

  var bordercolore = Colors.black38;
  var bordercolorp = Colors.black38;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 5), // Duration for the animation
      vsync: this,
    )..forward(); // Start the animation

    // Define the upper cloud animation (left to center)
    _upperCloudAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0), // Start off-screen on the left
      end: Offset(0.0, 0.0), // Stop at the center
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Define the lower cloud animation (right to center)
    _lowerCloudAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // Start off-screen on the right
      end: Offset(0.0, 0.0), // Stop at the center
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (_emailController.text == "") {
        showToast(message: 'Please Enter Email');
        bordercolore = Colors.red;
        _emailController.addListener(() {
          setState(() {
            bordercolore = Colors.black38;
          });
        });
      } else if (_passwordController.text == "") {
        showToast(message: "Please Enter Password");
        bordercolorp = Colors.red;
        _passwordController.addListener(() {
          setState(() {
            bordercolorp = Colors.black38;
          });
        });
      } else {
        showToast(message: 'An error occured: ${e.code}');
        bordercolore = Colors.red;
        bordercolorp = Colors.red;
        _emailController.addListener(() {
          setState(() {
            bordercolore = Colors.black38;
          });
        });
        _passwordController.addListener(() {
          setState(() {
            bordercolorp = Colors.black38;
          });
        });
      }
    }
    return null;
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    print(userCredential.user?.displayName);

    if (userCredential.user != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _signIn() async {
    setState(() {
      isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await signInWithEmailAndPassword(email, password);

    setState(() {
      isSigning = false;
    });

    if (user != null &&
        _emailController.text != "" &&
        _passwordController.text != "") {
      print("User is successfully Signed In");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else if (_emailController.text == "") {
      signInWithEmailAndPassword(email, password);
    }
  }

  void _onMenuSelected(String value, BuildContext context) {
    switch (value) {
      case 'About Us':
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Home clicked')));
        _showBlurDialogAboutus(context, value);
        break;
      case 'Instruction':
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings clicked')));
        _showBlurDialogInstructions(context, value);
        break;
      case 'PrivacyPolicy':
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout clicked')));
        _showBlurDialogPrivacy(context, value);
        break;
      case 'Terms & Conditions':
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout clicked')));
        _showBlurDialogTerms(context, value);
        break;
      case 'FAQ':
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout clicked')));
        _showBlurDialogFaq(context, value);
        break;
    }
  }

  void _showBlurDialogAboutus(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2), // Slightly dim background
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
              child: Container(
                color: Colors.black.withOpacity(0), // Needed to apply blur
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(title),
              content: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                    style: TextStyle(height: 2.h, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: "About AR Magic Lens\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "We are a team of passionate developers and educators focused on making learning fun and interactive for children."),
                      TextSpan(
                          text:
                          "\nThis project is part of our Final Year Project (FYP) in Software Engineering at NUML. Our goal was to blend technology and early education using Augmented Reality in a simple and engaging way."),
                      TextSpan(
                          text: "\nOur Mission:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "To provide children with a safe, educational, and exciting AR experience."),
                    ]),
              ),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showBlurDialogFaq(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2), // Slightly dim background
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
              child: Container(
                color: Colors.black.withOpacity(0), // Needed to apply blur
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(title),
              content: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                    style: TextStyle(height: 2.h, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                          "Q1: What age group is AR Magic Lens designed for?",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "\nA: It is best suited for children aged 3 to 8 years."),
                      TextSpan(
                          text: "\nQ2: Does this app require the internet?\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "A: No, basic features work offline. However, signing in, updates or additional content may need internet access."),
                      TextSpan(
                          text:
                          "\nQ3: Is it safe for my child to use the camera?\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "A: Yes, the camera is used only for object recognition and no images are stored."),
                    ]),
              ),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showBlurDialogInstructions(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2), // Slightly dim background
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
              child: Container(
                color: Colors.black.withOpacity(0), // Needed to apply blur
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(title),
              content: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                    style: TextStyle(height: 2.h, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: "Welcome To AR Magic Lens!\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "Our app helps kids learn object names and pronunciation using Augmented Reality (AR). Here’s how to get started:"),
                      TextSpan(
                          text: "\n1. Open the Camera:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "Give the app permission to use your camera."),
                      TextSpan(
                          text: "\n2. Scan Objects:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "Point your camera at real-world objects. The app will recognize them and speak out their names."),
                      TextSpan(
                          text: "\n3. Learn Pronunciation:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "Tap on the object name to hear the correct pronunciation."),
                      TextSpan(
                          text: "\n4. Use Interactive Mode:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "Some objects include animations or fun facts for better engagement."),
                      TextSpan(
                          text: "\n5. Keep the Environment Bright:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "For best results, scan in a well-lit environment."),
                    ]),
              ),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showBlurDialogPrivacy(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2), // Slightly dim background
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
              child: Container(
                color: Colors.black.withOpacity(0), // Needed to apply blur
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(title),
              content: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                    style: TextStyle(height: 2.h, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                          "Your child’s privacy is important to us. This app follows strict privacy guidelines to ensure a safe experience.\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "\n1. No Data Collection:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "We do not collect personal data or store images/videos."),
                      TextSpan(
                          text: "\n2. Camera Access:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "Camera is used only for object recognition in real-time. No data is saved or shared."),
                      TextSpan(
                          text: "\n3. No Ads:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "This app is ad-free to protect children from inappropriate content."),
                      TextSpan(
                          text: "\n4. Offline Mode:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          "Most features work without the internet, reducing data risks.Just need internet for login."),
                    ]),
              ),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showBlurDialogTerms(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2), // Slightly dim background
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
              child: Container(
                color: Colors.black.withOpacity(0), // Needed to apply blur
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(title),
              content: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                    style: TextStyle(height: 2.h, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                          "By using AR Magic Lens, you agree to the following terms:\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "\n1. The app is for educational use only."),
                      TextSpan(
                          text:
                          "\n2. Users must not misuse the app to capture or share inappropriate content."),
                      TextSpan(
                          text:
                          "\n3. We do not guarantee 100% accuracy in object recognition. It's a learning tool."),
                      TextSpan(
                          text:
                          "\n4.You agree not to reverse-engineer or redistribute the app without permission."),
                      TextSpan(
                          text:
                          "\n5. We may update features or policies at any time, and users will be notified accordingly."),
                    ]),
              ),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.sh,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              SlideTransition(
                position: _upperCloudAnimation,
                child: Container(
                  // color: Colors.red,
                  margin: EdgeInsets.only(top: 40.h),
                  child: Image.asset(
                    'assets/images/cloud_up.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SlideTransition(
                position: _lowerCloudAnimation,
                child: Container(
                  margin: EdgeInsets.only(top: 320.h),
                  child: Image.asset(
                    'assets/images/cloud_dn.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 45.h, left: 25.w),
                    child: ElevatedButton(
                      onPressed: () {
                        _launchURL(
                            'https://youtube.com/shorts/Qcjylri5VQI?feature=shared');
                        print('You Pressed On Take A Tour');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF90C2C6),
                      ),
                      child: Text(
                        'TRAILER',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    // color: Colors.red,
                    margin: EdgeInsets.only(top: 50.h, left: 200.w),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.menu, size: 50.h), // Icon to open menu
                      onSelected: (value) => _onMenuSelected(value, context),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'About Us',
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Colors.lightBlue[200],
                              ),
                              SizedBox(width: 10),
                              Text('About Us'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'FAQ',
                          child: Row(
                            children: [
                              Icon(
                                Icons.question_answer,
                                color: Colors.lightBlue[200],
                              ),
                              SizedBox(width: 10),
                              Text('FAQs'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'PrivacyPolicy',
                          child: Row(
                            children: [
                              Icon(
                                Icons.privacy_tip,
                                color: Colors.lightBlue[200],
                              ),
                              SizedBox(width: 10),
                              Text('Privacy Policy'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Instruction',
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                color: Colors.lightBlue[200],
                              ),
                              SizedBox(width: 10),
                              Text('Instructions'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                            value: 'Terms & Conditions',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_frames,
                                  color: Colors.lightBlue[200],
                                ),
                                SizedBox(width: 10),
                                Text('Terms & Conditions'),
                              ],
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 120.h),
                    child: Image.asset(
                      'assets/images/ar_logo.png',
                      height: 200.h,
                      width: 400.w,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 315.h),
                    padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 36.w, vertical: 10.h),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26.0.r),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26.0.r),
                            borderSide:
                            BorderSide(color: bordercolore, width: 2)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26.0.r),
                            borderSide:
                            BorderSide(color: bordercolore, width: 2)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26.0.r),
                            borderSide:
                            BorderSide(color: bordercolore, width: 2)),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        hintText: '    User Name',
                        fillColor: Colors.white,
                      ),
                      controller: _emailController,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 10.h),
                child: Container(
                  margin: EdgeInsets.only(top: 400.h),
                  child: TextFormField(
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26.0.r),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26.0.r),
                          borderSide:
                          BorderSide(color: bordercolorp, width: 2)),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26.0.r),
                          borderSide:
                          BorderSide(color: bordercolorp, width: 2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26.0.r),
                          borderSide:
                          BorderSide(color: bordercolorp, width: 2)),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      hintText: "    Password",
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.remove_red_eye,
                          color: Color(0xFF37878C),
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    controller: _passwordController,
                  ),
                ),
              ),
              Positioned(
                top: 500.h,
                right: 35.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotScreen()),
                        );
                        print('You Tapped Forgot Password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 530.h,
                left: 140.w,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    _signIn();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 150.w,
                    height: 50.h,
                    child: isSigning
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'GO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.sp,
                      ),
                    ),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 4,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(50.r),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFF5FE9F2),
                          Color(0xFF37878C),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 585.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: signInWithGoogle,
                      child: Container(
                        margin: EdgeInsets.only(top: 10.h, left: 90.w),
                        width: 250.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.r),
                            color: Colors.transparent,
                            border: Border.all(color: Colors.black38),
                            boxShadow: [
                              BoxShadow(color: Colors.white70, blurRadius: 4)
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50.w,
                              height: 50.h,
                              child: Image.asset('assets/images/google.png'),
                            ),
                            Container(
                              width: 170.w,
                              child: const Text(
                                '  Continue With Google',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 655.h),
                    child: Text(
                      "Don't have an account yet?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                      print('You Tapped Sign Up');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 655.h),
                      child: Text(
                        ' Sign Up',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void popupmenu() {
  PopupMenuButton(itemBuilder: (_) {
    return [
      PopupMenuItem(
        child: Row(
          children: [Icon(Icons.settings), Text("Settings")],
        ),
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context)=>settings()));
        },
      )
    ];
  });
}