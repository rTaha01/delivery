import 'package:delivery_app/auth/phoneInput/phoneCode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/fetchNumber.dart';
import '../utlis/common_widget.dart';

class ChooseNumber extends StatefulWidget {
  const ChooseNumber({super.key});

  @override
  State<ChooseNumber> createState() => _ChooseNumberState();
}

class _ChooseNumberState extends State<ChooseNumber> {
  String? userPhoneNumber = currentUserPhoneNumber();

  String number = "+92";
  TextEditingController phone = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _verifyPhoneNumber(String? phoneNumber, context) async {
    try {
      if (phoneNumber == null || phoneNumber.isEmpty) {
        CommonWidget.toastMessage("Phone number is required");
      } else if (!RegExp(
        r'^\+?(?:[0-9]\s?){6,14}[0-9]$',
      ).hasMatch(phoneNumber)) {
        CommonWidget.toastMessage("Invalid phone number format");
      } else {
        CommonWidget.loader(context);
        await _auth.verifyPhoneNumber(
          phoneNumber: number + phone.text,
          verificationCompleted: (_) async {},
          verificationFailed: (e) {
            if (e.code == 'invalid-phone-number' ||
                e.code == 'wrong-password') {
              CommonWidget.toastMessage('Invalid phone number');
            } else if (e.code == "too-many-requests") {
              CommonWidget.toastMessage(
                  "you have try too many request! please try later.");
            } else if (e.code == "web-context-cancelled") {
              CommonWidget.toastMessage("Otp request cancelled.");
            } else {
              CommonWidget.toastMessage('Error occurred: ${e.code}');
              print('An error occurred: ${e.code}');
            }
            Navigator.pop(context);
          },
          codeSent: (String verificationId, int? token) {
            print("Code Sent");
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => PhonePIN(
                    number: number + phone.text,
                    verificationId: verificationId,
                  ),
                ),
                (route) => true);
          },
          codeAutoRetrievalTimeout: (e) {
            CommonWidget.toastMessage("Error! $e");
          },
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print("Unexpected Error: $e");
      CommonWidget.toastMessage(
          "An unexpected error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 150.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.0.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Номер менен кириңиз",
                    style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black),
                  ),
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.0.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Телефон',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.0.w, right: 30.0.w),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: phone,
                  maxLines: 1,
                  onSaved: (value) {},
                  minLines: 1,
                  cursorColor: Colors.black,
                  cursorHeight: 18.h,
                  cursorWidth: 1.5.w,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 0.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 17.0, horizontal: 8.0),
                        child: Text(
                          number,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      hintText: "987654321",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      )),
                  style:
                      TextStyle(fontSize: 14.0.sp, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w),
                  height: 40.h,
                  child: MaterialButton(
                    color: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      _verifyPhoneNumber(
                        phone.text.toString(),
                        context,
                      );
                      print(userPhoneNumber);
                    },
                    child: SizedBox(
                      height: 40.0.h,
                      child: Center(
                        child: Text(
                          "Кирүү",
                          style: TextStyle(
                              fontSize: 17.0.sp,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
