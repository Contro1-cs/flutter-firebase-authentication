import 'package:encryption/home.dart';
import 'package:encryption/main.dart';
import 'package:encryption/widgets/custom_snackbars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  const OTPPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    TapGestureRecognizer tapRecogniser = TapGestureRecognizer()
      ..onTap = () {
        Get.back();
      };
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Text(
              'OTP Verification',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'An OTP has been sent to ',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '+91 ${widget.phoneNumber}.\n',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Change phone number',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    recognizer: tapRecogniser..onTap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Pinput(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              length: 6,
              controller: otpController,
              focusedPinTheme: PinTheme(
                constraints: const BoxConstraints(
                    maxWidth: 45, minWidth: 45, minHeight: 60, maxHeight: 60),
                textStyle: GoogleFonts.poppins(
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              defaultPinTheme: PinTheme(
                constraints: const BoxConstraints(
                    maxWidth: 45, minWidth: 45, minHeight: 60, maxHeight: 60),
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  fontSize: 20,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 0,
                ),
                decoration: BoxDecoration(
                  color: red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const Expanded(child: SizedBox()),
            Container(
              width: w,
              height: 60,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000),
                  ),
                ),
                onPressed: () async {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationId,
                    smsCode: otpController.text,
                  );
                  await FirebaseAuth.instance
                      .signInWithCredential(credential)
                      .then((value) {
                    successSnackbar(context, 'user authenticated');
                    Get.to(const HomePage());
                  }).onError(
                    (FirebaseException error, stackTrace) {
                      if (error.code == 'invalid-verification-code') {
                        return errorSnackbar(context, 'Wrong OTP');
                      } else {
                        return errorSnackbar(context, error.code);
                      }
                    },
                  );
                },
                child: Text(
                  'Validate OTP',
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
