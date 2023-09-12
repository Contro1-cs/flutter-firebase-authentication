import 'package:encryption/main.dart';
import 'package:encryption/onboarding/otp_page.dart';
import 'package:encryption/widgets/custom_snackbars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

bool _loading = false;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

TextEditingController _phoneNumber = TextEditingController();

class _SignupPageState extends State<SignupPage> {
  Future<void> authenticateWithPhoneNumber() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91${_phoneNumber.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatic handling of SMS code on Android devices
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            errorSnackbar(context, 'The provided phone number is not valid.');
          } else {
            errorSnackbar(
                context, 'Verification failed. Error code: ${e.toString()}');
            debugPrint('Verification failed. Error code: ${e.toString()}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          HapticFeedback.vibrate();
          Get.to(
            OTPPage(
              phoneNumber: _phoneNumber.text,
              verificationId: verificationId,
            ),
            transition: Transition.cupertino,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      errorSnackbar(
          context, 'An error occurred during phone authentication: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),
                  Text(
                    'Signup',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    width: w,
                    alignment: Alignment.center,
                    child: TextFormField(
                      controller: _phoneNumber,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      cursorColor: red,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'Your 10 digit phone number',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: red, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: w,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          _loading = true;
                        });
                        authenticateWithPhoneNumber();
                        setState(() {
                          _loading = false;
                        });
                      },
                      child: Text(
                        'Send OTP',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
