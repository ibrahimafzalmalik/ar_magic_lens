import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '2_home_screen.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../global/common/toast.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;
  File? _imageFile;
  bool _obscureText = true;
  static bool isSigningUp = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  static var bordercoloru = Colors.black38;
  static var bordercolore = Colors.black38;
  static var bordercolorp = Colors.black38;
  static var bordercolori = Colors.black38;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } catch (e) {
      showErrorDialog("Failed to sign in with Google: $e");
    }
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
        SignUpScreenState.bordercolore = Colors.red;
      } else if (e.code == "") {
        bordercolore = Colors.red;
        showToast(message: 'Please Enter a valid email Email');
        _emailController.addListener(() {
          setState(() {
            bordercolore = Colors.black38;
          });
        });
      } else if (e.code == 'weak-password') {
        showToast(message: 'Password must be at least 6 characters long.');
        setState(() {
          isSigningUp = false;
        });
        bordercolorp = Colors.red;
        _passwordController.addListener(() {
          setState(() {
            bordercolorp = Colors.black38;
          });
        });
      } else {
        showToast(message: 'An error occured: ${e.code}');
        setState(() {
          isSigningUp = false;
        });
      }
    }
    return null;
  }

  Future<void> pickImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (res != null) {
        setState(() {
          _imageFile = File(res.path);
          bordercolori = Colors.black38;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to pick image: $e"),
        ),
      );
    }
  }

  Future<void> uploadImageToFirebase(File image) async {
    try {
      Reference reference = FirebaseStorage.instance
          .ref()
          .child("images/${DateTime.now().microsecondsSinceEpoch}.png");

      // ✅ Upload the file first
      UploadTask uploadTask = reference.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // ✅ Then get the download URL
      imageUrl = await snapshot.ref.getDownloadURL();

      if (imageUrl == "") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Please upload a profile picture."),
          ),
        );
      }
      else {
        // ✅ You can now use imageUrl
        print("Image uploaded. URL: $imageUrl");

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to upload image: $e"),
        ),
      );
      print("FAILED TO UPLOAD: $e");
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });
    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await signUpWithEmailAndPassword(email, password);

    if (_imageFile != null &&
        _usernameController.text != "" &&
        _emailController.text != "" &&
        _passwordController.text != "") {
      await uploadImageToFirebase(_imageFile!);
      await user!.updateDisplayName(_usernameController.text);
      await user.updatePhotoURL(imageUrl);

      print("User is successfully Signed Up");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("You are successfully Signed Up"),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }

    if (_imageFile == null) {
      bordercolori = Colors.red;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please upload a profile picture."),
        ),
      );
    } else if (_usernameController.text == "") {
      bordercoloru = Colors.red;
      _usernameController.addListener(() {
        setState(() {
          bordercoloru = Colors.black38;
        });
      });
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
        .hasMatch(_emailController.text)) {
      bordercolore = Colors.red;
      showToast(message: 'Please Enter a valid email Email');
      signUpWithEmailAndPassword(email, password);
    } else if (_passwordController.text == "") {
      bordercolorp = Colors.red;
      showToast(message: 'Please Enter Password');
      signUpWithEmailAndPassword(email, password);
    }

    setState(() {
      isSigningUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.sh,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 350.w,
                    height: 220.h,
                    margin: EdgeInsets.only(top: 50.h),
                    child: Image.asset('assets/images/ar_logo.png'),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20.h),
                child: Text(
                  'Create Account',
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
                ),
              ),
              SizedBox(height: 3.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: bordercolori, width: 2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        _imageFile != null
                            ? CircleAvatar(
                          radius: 64.r,
                          backgroundImage: FileImage(_imageFile!),
                        )
                            : CircleAvatar(
                          radius: 64.r,
                          backgroundImage: const AssetImage(
                              'assets/images/avatar.png'),
                        ),
                        Positioned(
                          // top: 8.h,
                          // left: 33.w,
                          child: IconButton(
                            onPressed: pickImage,
                            icon: const Icon(Icons.add_a_photo,
                                color: Colors.black, size: 25),
                          ),
                          top: -10.h,
                          left: 85.w,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8.h),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 36.w),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide(color: bordercoloru, width: 2)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide(color: bordercoloru, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide(color: bordercoloru, width: 2)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide(color: bordercoloru, width: 2)),
                  ),
                ),
              ),
              Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 10.h, horizontal: 36.w),
                  child: TextFormField(
                    // keyboardType: TextInputType.emailAddress,  // Sets the keyboard to email type

                    validator: (value) {
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },

                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Your Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                          BorderSide(color: bordercolore, width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                          BorderSide(color: bordercolore, width: 2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                          BorderSide(color: bordercolore, width: 2)),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                          BorderSide(color: bordercolore, width: 2)),
                    ),
                  )),
              Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 10.h, horizontal: 36.w),
                  child: TextField(
                    obscureText: _obscureText,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Your Password',
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.remove_red_eye,
                          color: const Color(0xFF37878C),
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                          BorderSide(color: bordercolorp, width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                          BorderSide(color: bordercolorp, width: 2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                          BorderSide(color: bordercolorp, width: 2)),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                          BorderSide(color: bordercolorp, width: 2)),
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(top: 15.h),
                width: 154.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    gradient: const LinearGradient(colors: [
                      Color(0xFF5FE9F2),
                      Color(0xFF37878C),
                    ]),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)]),
                child: Container(
                  alignment: Alignment.center,
                  width: 100.w,
                  height: 50.h,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: _signUp,
                    child: isSigningUp
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: signInWithGoogle,
                child: Container(
                  margin: EdgeInsets.only(top: 10.h),
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
                        // margin: EdgeInsets.only(top: 10.h),
                        child: Image.asset('assets/images/google.png'),
                      ),
                      Container(
                        // margin: EdgeInsets.only(top: 20.h),
                        width: 170.w,
                        child: const Text(
                          'Continue With Google',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LogIn()));
                      },
                      child: GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          child: const Text(
                            " Sign In",
                            style: TextStyle(color: Color(0xFF048D2A)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}