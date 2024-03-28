import 'package:delivery_app/utlis/common_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utlis/color_codes.dart';
import '../home/main_page.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({
    super.key,
  });
  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  GoogleMapsPlaces? places;
  List<Prediction> predictionsList = [];

  final _formKey = GlobalKey<FormState>();
  File? _image;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> _getPredictions(String select) async {
    if (select.isEmpty) {
      setState(() {
        predictionsList.clear();
      });
      return;
    }

    final getValue = await places!.autocomplete(
      select,
      location: Location(lat: 0, lng: 0),
      radius: 10,
      language: 'en',
      types: ['address'],
      components: [Component(Component.country, 'KG')],
    );

    if (getValue.isOkay) {
      setState(() {
        predictionsList = getValue.predictions;
      });
    } else {
      if (kDebugMode) {
        print(getValue.errorMessage);
      }
    }
  }

  Future<void> selectPlace(Prediction choosePlace) async {
    setState(() {
      _addressController.text = choosePlace.description.toString();
      predictionsList.clear();
    });
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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
    print('Compressed image size: ${(compressedSize / 1024).toStringAsFixed(1)} KB');

    return await imageRef.getDownloadURL();
  }

  Future<void> _saveProfile(
    String name,
    String email,
    String address,
    context,
  ) async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_image == null) {
          return CommonWidget.toastMessage("Please Select Image");
        } else if (name == "" || name.isEmpty || name.length > 4) {
          CommonWidget.toastMessage("Enter your name");
        } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([a-z\d-]+\.)+[a-z]{2,}$')
            .hasMatch(email)) {
          CommonWidget.toastMessage("Please! Enter Email correctly");
        } else if (address == '' || address.isEmpty) {
          CommonWidget.toastMessage("Please! Enter address");
        } else {
          CommonWidget.loader(context);
          final downloadUrl = await _uploadImage();
          await FirebaseFirestore.instance
              .collection("delivery")
              .doc('Profile Info').set({
            'name': _nameController.text,
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
    places =
        GoogleMapsPlaces(apiKey: "AIzaSyDydH0mmsu6erSxfXK31BCrjQwnv7HiqdM");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: SingleChildScrollView(
        // If form is long
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                      height: 130.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: Colors.grey.shade300, width: 0.5)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: _image != null
                            ? Image.file(
                                _image!,
                                fit: BoxFit.fill,
                              )
                            : const Icon(Icons.person, size: 60),
                      )),
                ),
                SizedBox(
                  height: 25.h,
                ),
                SizedBox(
                  height: 48.h,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 5.0.w,
                      right: 5.w,
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      cursorColor: Colors.black,
                      cursorHeight: 13.h,
                      cursorWidth: 1.5.w,
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
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.account_circle_rounded,
                            color: Colors.black,
                          ),
                          hintText: "Enter Your Name",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 14.sp,
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
                  height: 48.h,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 5.0.w,
                      right: 5.w,
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      cursorColor: Colors.black,
                      cursorHeight: 13.h,
                      cursorWidth: 1.5.w,
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
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          hintText: "Enter Your Email",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 14.sp,
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
                  height: 48.h,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 5.0.w,
                      right: 5.w,
                    ),
                    child: TextFormField(
                      controller: _addressController,
                      cursorColor: Colors.black,
                      cursorHeight: 13.h,
                      cursorWidth: 1.5.w,
                      onChanged: (value) {
                        _getPredictions(value);
                        if (kDebugMode) {
                          print("Address : $_getPredictions");
                        }
                      },
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 0.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_on_sharp,
                            color: Colors.black,
                          ),
                          hintText: "Enter Your Address",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 14.sp,
                          )),
                      style: TextStyle(
                          fontSize: 13.0.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                if (predictionsList.isNotEmpty)
                  SizedBox(
                    height: 148.h,
                    child: ListView.builder(
                      itemCount: predictionsList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            SizedBox(height: 5.h),
                            GestureDetector(
                              onTap: () {
                                selectPlace(predictionsList[index]);
                              },
                              child: Row(
                                children: [
                                  SizedBox(width: 22.w),
                                  Icon(
                                    Icons.location_pin,
                                    color: Colors.black87,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    predictionsList[index]
                                        .description
                                        .toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.0.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Container(
                              height: 0.2.h,
                              width: 320.w,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        );
                      },
                    ),
                  )
                else
                  const SizedBox.shrink(),
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
                            _nameController.text.toString(),
                            _emailController.text.toString(),
                            _addressController.text.toString(),
                            context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.cyan),
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
