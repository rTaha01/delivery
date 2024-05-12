import 'package:delivery_app/utlis/common_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controller/fetchNumber.dart';
import '../../utlis/color_codes.dart';
import '../../widgets/loader.dart';
import '../home/main_page.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({
    super.key,
  });
  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {


  final _formKey = GlobalKey<FormState>();
  File? _image;
  String? profileImageUrl;
  final _nameController = TextEditingController();
  final numberController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();



  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  Future<void> fetchProfileDetails() async {
    String? phoneNumber = currentUserPhoneNumber();
    final profileDoc = await FirebaseFirestore.instance
        .collection("userProfile")
        .doc(phoneNumber)
        .get();
    if (profileDoc.exists) {
      setState(() {
        _nameController.text = profileDoc['name'];
        numberController.text = profileDoc['number'];
        _emailController.text = profileDoc['email'];
        _addressController.text = profileDoc['address'];
        profileImageUrl = profileDoc['profileImageUrl'];
      });
    }
  }
  Future<String> _uploadImage() async {
    final storageRef = FirebaseStorage.instance.ref();
    final user = FirebaseAuth.instance.currentUser!;
    final imageRef = storageRef.child('profile_images/${user.uid}.jpg');
    final directory = await path_provider.getTemporaryDirectory();
    final compressedImage = imageLib.decodeImage(_image!.readAsBytesSync());
    final compressedImageFile = File('${directory.path}/compressed_image.jpg')
      ..writeAsBytesSync(imageLib.encodeJpg(compressedImage!, quality: 80));
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'uploadedBy': user.uid,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    await imageRef.putFile(compressedImageFile, metadata);
    final compressedSize = await compressedImageFile.length();
    print(
        'Compressed image size: ${(compressedSize / 1024).toStringAsFixed(1)} KB');

    return await imageRef.getDownloadURL();
  }

  Future<void> _saveProfile(
    String name,
    String? number,
    String email,
    String address,
    context,
  ) async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_image == null) {
          return CommonWidget.toastMessage("Please Select Image");
        } else if (name == "" || name.isEmpty || name.length < 4) {
          CommonWidget.toastMessage("Enter your name");
        } else if (number == null || number.isEmpty) {
          CommonWidget.toastMessage("Phone number is required");
        } else if (!RegExp(
          r'^\+?(?:[0-9]\s?){6,14}[0-9]$',
        ).hasMatch(number)) {
          CommonWidget.toastMessage("Invalid phone number format");
        }

        else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([a-z\d-]+\.)+[a-z]{2,}$')
            .hasMatch(email)) {
          CommonWidget.toastMessage("Please! Enter Email correctly");
        } else if (address == '' || address.isEmpty) {
          CommonWidget.toastMessage("Please! Enter address");
        } else {
          CommonWidget.loader(context);
          String? phoneNumber = currentUserPhoneNumber();
          final downloadUrl = await _uploadImage();
          await FirebaseFirestore.instance
              .collection("userProfile")
              .doc(phoneNumber!)
              .set({
            'name': _nameController.text,
            'number': numberController.text,
            'address': _addressController.text,
            'email': _emailController.text,
            'profileImageUrl': downloadUrl,
          }, SetOptions(merge: true));
          await FirebaseFirestore.instance
              .collection("userProfile")
              .doc(phoneNumber)
              .update({
            'name': _nameController.text,
            'number': numberController.text,
            'address': _addressController.text,
            'email': _emailController.text,
            'profileImageUrl': downloadUrl,
          });

          Navigator.pop(context);
          CommonWidget.toastMessage("Profile upload");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      } on FirebaseException catch (e) {
        CommonWidget.toastMessage("Error: $e");
        print("Error: $e");
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Setup',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 17.sp),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 18.sp,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // If form is long
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _selectImage,
                      child: Container(
                        height: 130.h,
                        width: 150.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _image != null
                              ? Image.file(
                            _image!,
                            fit: BoxFit.fill,
                          )
                              : profileImageUrl != null
                              ? Image.network(
                            profileImageUrl!,
                            fit: BoxFit.fill,
                          )
                              : Icon(
                            Icons.person,
                            size: 80.sp,
                            color: hintColor,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _selectImage,
                      child: Padding(
                        padding:  EdgeInsets.only(left: 100.w,top: 100.h),
                        child: Container(
                          height: 30.h,
                          width: 50.w,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orangeAccent
                          ),
                          child: const Center(
                            child: Icon(Icons.edit,color: Colors.black,size: 20,),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 25.h,
                ),
                SizedBox(
                  height: 40.h,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 5.0.w,
                      right: 5.w,
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      cursorColor: Colors.black,
                      cursorHeight: 20.h,
                      cursorWidth: 1.w,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 0.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: hintColor, width: 1.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.account_circle_rounded,
                            color: Colors.black87,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                          hintText: "Enter Your Name",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 13.sp,
                          )),
                      style: TextStyle(
                          fontSize: 13.0.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                SizedBox(
                  height: 40.h,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 5.0.w,
                      right: 5.w,
                    ),
                    child: TextFormField(
                      controller: numberController,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.number,
                      cursorHeight: 20.h,
                      cursorWidth: 1.w,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 0.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            BorderSide(color: hintColor, width: 1.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.account_circle_rounded,
                            color: Colors.black87,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                          hintText: "Enter Your Number",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 13.sp,
                          )),
                      style: TextStyle(
                          fontSize: 13.0.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                SizedBox(
                  height: 40.h,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 5.0.w,
                      right: 5.w,
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      cursorColor: Colors.black,
                      cursorHeight: 20.h,
                      cursorWidth: 1.w,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 0.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: hintColor, width: 1.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.black87,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                          hintText: "Enter Your Email",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 13.sp,
                          )),
                      style: TextStyle(
                          fontSize: 13.0.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                SizedBox(
                  height: 40.h,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 5.0.w,
                      right: 5.w,
                    ),
                    child: TextFormField(
                      controller: _addressController,
                      cursorColor: Colors.black,
                      cursorHeight: 20.h,
                      cursorWidth: 1.w,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 0.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: hintColor, width: 1.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_on_sharp,
                            color: Colors.black87,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                          hintText: "Enter Your Home Address",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 13.sp,
                          )),
                      style: TextStyle(
                          fontSize: 13.0.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                  child: SizedBox(
                    height: 40.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveProfile(
                            _nameController.text.trim(),
                            numberController.text.trim(),
                            _emailController.text.trim(),
                            _addressController.text.trim(),
                            context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(hintColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: Text(
                        'Save Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0.sp,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
