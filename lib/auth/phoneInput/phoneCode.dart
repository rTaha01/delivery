import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/screens/home/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../../utlis/color_codes.dart';
import '../../../utlis/common_widget.dart';
import '../../controller/fetchNumber.dart';
import '../../widgets/loader.dart';

class PhonePIN extends StatefulWidget {
  final String number;
  final String verificationId;

  const PhonePIN(
      {super.key, required this.number, required this.verificationId});

  @override
  State<PhonePIN> createState() => _PhonePINState();
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
String pinField = '';

final defaultPinTheme = PinTheme(
  height: 45.h,
  width: 50.w,
  textStyle: TextStyle(
      fontSize: 20.sp, color: primaryColor, fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: const Color.fromRGBO(23, 22, 22, 1.0)),
    borderRadius: BorderRadius.circular(8),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: Colors.cyan, width: 3),
  borderRadius: BorderRadius.circular(8),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration?.copyWith(
    color: Colors.cyan,
  ),
);

class _PhonePINState extends State<PhonePIN> {
  void _submitForm(context, String? pin) async {
    if (_formKey.currentState!.validate()) {
      try {
        if (pin == null || pin.isEmpty) {
          CommonWidget.toastMessage("Сураныч, кодду киргизиңиз");
        } else if (pin.length < 6) {
          CommonWidget.toastMessage("PIN кеминде 6 сандан турушу керек");
        } else {
          Loader();
          final credential = PhoneAuthProvider.credential(
            verificationId: widget.verificationId,
            smsCode: pin,
          );
          await FirebaseAuth.instance.signInWithCredential(credential);
          String? phoneNumber = currentUserPhoneNumber();
          if (phoneNumber != null) {
            await FirebaseFirestore.instance.collection(phoneNumber);
            print("Firestore collection created at $phoneNumber");
          } else {
            print("Error: Phone number is null");
          }

          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ),
              (route) => false);
        }
      } catch (e) {
        CommonWidget.toastMessage("Invalid OTP");
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 120.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Кодду текшерүү",
                    style: TextStyle(
                        fontSize: 25.0.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text:
                          "Сиздин смс кутусун текшериңиз, биз жөнөттүк.\nсен код at ",
                      style: TextStyle(
                          fontSize: 16.0.sp,
                          fontFamily: "Light",
                          height: 1.2.h,
                          color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: widget.number,
                            style: TextStyle(
                                fontSize: 17.0.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                                color: Colors.cyan)),
                      ],
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              SizedBox(
                height: 25.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 21.0.w, right: 20.w),
                child: Pinput(
                  obscureText: true,
                  length: 6,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      pinField = value;
                    });
                  },
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  showCursor: true,
                  onCompleted: (pin) => pin,
                ),
              ),
              SizedBox(
                height: 25.h,
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20.w, right: 20.w),
                height: 40.h,
                child: MaterialButton(
                  color: Colors.cyan,
                  textColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    _submitForm(context, pinField);
                  },
                  child: SizedBox(
                    height: 45.0.h,
                    child: Center(
                      child: Text(
                        "Кодду текшерүү",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            fontSize: 17.0.sp,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 25.w),
                  child: Text(
                    "Кодду кайра жөнөтүү!",
                    style: TextStyle(color: Colors.black, fontSize: 11.sp),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
