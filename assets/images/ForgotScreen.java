import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../global/common/toast.dart';
import 'main.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({Key? key}) : super(key: key);

  @override
  State<ForgotScreen> createState() => ForgotScreenState();
}

class ForgotScreenState extends State<ForgotScreen> {
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 932.h,
      decoration: BoxDecoration(
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
                    margin: EdgeInsets.only(top: 50.h),
                    width: 350.w,
                    height: 180.h,
                    child: Image.asset('assets/images/ar_logo.png'),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 20.h),
                width: 350.w,
                height: 220.h,
                alignment: Alignment.topCenter,
                child: Image.asset('assets/images/fkids.png'),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.h),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.h),
                child: Padding(
                  padding: EdgeInsets.all(30.w),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26.r)),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      hintText: '    Your Email Address',
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  String email = emailController.text.trim();

                  try {
                    // Try to fetch sign-in methods for the email
                    final list = await auth.fetchSignInMethodsForEmail(email);
                    
                    if (list.isNotEmpty) {
                      // Email exists, proceed with password reset
                      await auth.sendPasswordResetEmail(email: email);
                      showToast(message: 'We have sent you an email to recover your password, please check your email.');
                    } else {
                      // Email does not exist
                      showToast(message: 'No user found with this email.');
                    }
                  } catch (error) {
                    showToast(message: 'Error occurred: ${error.toString()}');
                  }

                  // Navigate back to the login screen
                  Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) => LogIn()),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  width: 150.w,
                  height: 50.h,
                  child: Text(
                    'SEND',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.sp),
                  ),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.grey, blurRadius: 4)
                      ],
                      borderRadius: BorderRadius.circular(50.r),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFF5FE9F2),
                          Color(0xFF37878C),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
