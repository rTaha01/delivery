import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/screens/profile_info/profile_info.dart';
import 'package:delivery_app/utlis/common_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:marquee/marquee.dart';
import '../../auth/chooseNumber.dart';
import '../../controller/contact_controller.dart';
import '../../controller/fetchNumber.dart';
import '../../utlis/color_codes.dart';
import '../../widgets/text_field_widget.dart';
import '../application/application_req.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

List textList = [
  {"id": 1, "text": 'banner 1'},
  {"id": 2, "text": 'banner 2'},
  {"id": 3, "text": 'banner 3'}
];
final CarouselController carouselController = CarouselController();
int currentIndex = 0;
String contactNumber = "+996558149761";
TextEditingController nameController = TextEditingController();
TextEditingController numberController = TextEditingController();
TextEditingController addressController = TextEditingController();
TextEditingController moneyController = TextEditingController();
TextEditingController additionalInfo = TextEditingController();
String number = "+92";
bool? _isPay = false;
final firestore = FirebaseFirestore.instance;

class _MainScreenState extends State<MainScreen> {
  GoogleMapsPlaces? _places;
  List<Prediction> _predictions = [];

  Future<void> _getPlacePredictions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _predictions.clear();
      });
      return;
    }

    final response = await _places!.autocomplete(
      input,
      location: Location(lat: 0, lng: 0),
      radius: 10,
      language: 'en',
      types: ['address'],
      components: [Component(Component.country, 'KG')],
    );

    if (response.isOkay) {
      setState(() {
        _predictions = response.predictions;
      });
    } else {
      if (kDebugMode) {
        print(response.errorMessage);
      }
    }
  }

  void _selectPlace(Prediction selectedPlace) {
    setState(() {
      addressController.text = selectedPlace.description.toString();
      _predictions.clear();
    });
  }

  String generateOrderNumber() {
    int randomInt = Random().nextInt(900000) +
        100000; // Random integer between 100000 and 999999
    return "#$randomInt";
  }

  Future<void> _saveApplication(
    String name,
    String phone,
    String address,
    String money,
    isPay,
    String additionInformation,
  ) async {
    String? phoneNumber = currentUserPhoneNumber();
    String orderNumber = generateOrderNumber();
    if (name.isEmpty || name == "") {
      CommonWidget.toastMessage("Please Enter the name");
    } else if (!RegExp(
      r'^\+?(?:[0-9]\s?){6,14}[0-9]$',
    ).hasMatch(phone)) {
      CommonWidget.toastMessage("Invalid phone number format");
    } else if (address.isEmpty || address == "") {
      CommonWidget.toastMessage("Enter your address");
    } else if (money.isEmpty || money == "") {
      CommonWidget.toastMessage("Enter Price");
    } else if (isPay == null) {
      CommonWidget.toastMessage("Select Price Status");
    } else if (additionInformation.isEmpty || additionInformation == "") {
      CommonWidget.toastMessage("Add Some additional information");
    } else {
      Map<String, dynamic> requestData = {
        'orderNo': orderNumber,
        'name': nameController.text,
        'phone': number + numberController.text,
        'address': addressController.text,
        'price': moneyController.text,
        'paymentStatus':
            isPay != null ? (isPay ? 'PAID' : 'UNPAID') : 'UNKNOWN',
        'additionalInfo': additionalInfo.text,
        "date": DateTime.now(),
      };
      try {
        CommonWidget.loader(context);
        await FirebaseFirestore.instance
            .collection(phoneNumber!)
            .doc("applicationRequest $orderNumber")
            .set(requestData);
        // String requestUID = docRef.id;
        //
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // List<String>? storedUIDs = prefs.getStringList('deliveryUIDs');
        // if (storedUIDs != null) {
        //   storedUIDs.add(requestUID);
        // } else {
        //   storedUIDs = [requestUID];
        // }
        // await prefs.setStringList('deliveryUIDs', storedUIDs);
        Navigator.pop(context);
        _showSubmitSuccessDialog();
        print("Application request saved with order number: $orderNumber");
        setState(() {
          nameController.clear();
          numberController.clear();
          addressController.clear();
          moneyController.clear();
          additionalInfo.clear();
          isPay = false;
        });
      } catch (e) {
        Navigator.pop(context);
        print('Error saving request: $e');
        CommonWidget.toastMessage(
            "Failed to submit request. Please try again later");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _places =
        GoogleMapsPlaces(apiKey: "AIzaSyDydH0mmsu6erSxfXK31BCrjQwnv7HiqdM");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  height: 80.h,
                  width: 360.w,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      offset: const Offset(4, 3),
                    )
                  ]),
                  child: CarouselSlider(
                    items: textList
                        .map(
                          (item) => Text(
                            item['text'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 35),
                          ),
                        )
                        .toList(),
                    carouselController: carouselController,
                    options: CarouselOptions(
                      scrollPhysics: const BouncingScrollPhysics(),
                      autoPlay: true,
                      aspectRatio: 7,
                      viewportFraction: 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  height: 15.h,
                  child: Marquee(
                    text: 'Ticker Text will be here       ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Stack(
                  children: [
                    Opacity(
                        opacity: 0.3,
                        child: Image.asset(
                          "assets/images/oboia.png",
                          fit: BoxFit.fill,
                          height: 520.h,
                          width: double.infinity,
                        )),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 15.h),
                          child: CommonField.customField(
                            TextInputType.name,
                            nameController,
                            "Ф.И.О консультанта",
                            const Icon(
                              Icons.account_circle,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15.h),
                          child: CommonField.customField(
                            TextInputType.phone,
                            numberController,
                            "Телефон",
                            const Icon(
                              Icons.phone,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15.h),
                          height: 40.h,
                          padding: EdgeInsets.only(left: 10.0.w, right: 10.w),
                          width: double.infinity,
                          child: TextFormField(
                            controller: addressController,
                            onChanged: (value) {
                              _getPlacePredictions(value);
                              if (kDebugMode) {
                                print("Address : $_getPlacePredictions");
                              }
                            },
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
                                contentPadding: const EdgeInsets.all(10),
                                prefixIcon: Icon(
                                  Icons.location_pin,
                                  color: Colors.black87,
                                  size: 18.sp,
                                ),
                                hintText: 'Адрес (2гис)',
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 13.sp,
                                )),
                            style: TextStyle(
                                fontSize: 13.0.sp, fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (_predictions.isNotEmpty)
                          SizedBox(
                            height: 148.h,
                            child: ListView.builder(
                              itemCount: _predictions.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    SizedBox(height: 5.h),
                                    GestureDetector(
                                      onTap: () {
                                        _selectPlace(_predictions[index]);
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
                                            _predictions[index]
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
                        Container(
                          margin: EdgeInsets.only(top: 10.h),
                          child: CommonField.customField(
                            TextInputType.number,
                            moneyController,
                            "ОПЛАТА",
                            const Icon(
                              Icons.attach_money,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0.w, right: 10.w),
                          child: GestureDetector(
                            onTap: () {
                              if (_isPay != null) {
                                setState(() {
                                  _isPay = true;
                                });
                              } else {
                                CommonWidget.toastMessage(
                                    "Please Select the one of the payment options!");
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 40.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Radio(
                                    value: true,
                                    activeColor: Colors.green,
                                    groupValue: _isPay,
                                    onChanged: (value) {
                                      setState(() {
                                        _isPay = value as bool;
                                      });
                                    },
                                  ),
                                  const Text(
                                    "төлөнгөн",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0.w, right: 10.w),
                          child: GestureDetector(
                            onTap: () {
                              if (_isPay != null) {
                                setState(() {
                                  _isPay = false;
                                });
                              } else {
                                CommonWidget.toastMessage(
                                    "Please Select the one of the payment options!");
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 40.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Radio(
                                    groupValue: _isPay,
                                    activeColor: Colors.red,
                                    onChanged: (value) {
                                      setState(() {
                                        _isPay = value as bool;
                                      });
                                    },
                                    value: false,
                                  ),
                                  const Text(
                                    "төлөнбөгөн (демейки)",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Container(
                          width: double.infinity,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.3),
                          ),
                          child: TextFormField(
                            controller: additionalInfo,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Дополнительная информац...",
                                hintStyle: TextStyle(
                                    color: hintColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600),
                                prefixIcon: const Icon(
                                  Icons.info,
                                  color: Colors.black,
                                  size: 20,
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            _saveApplication(
                                nameController.text,
                                numberController.text,
                                addressController.text,
                                moneyController.text,
                                _isPay,
                                additionalInfo.text);
                          },
                          child: Container(
                            height: 45.h,
                            width: 180.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.black, width: 2)),
                            child: const Center(
                              child: Text(
                                "ОСТАВИТЬ ЗАЯВКУ",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ApplicationRequest()));
                          },
                          child: Container(
                            height: 45.h,
                            width: 200.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.red, width: 5)),
                            child: const Center(
                              child: Text(
                                "МОИ ЗАЯВКИ",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: hintColor,
          elevation: 0,
          children: [
            SpeedDialChild(
              backgroundColor: Colors.white,
              elevation: 0,
              label: "Profile",
              labelShadow: [],
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileSetup()));
              },
              child: Icon(
                Icons.account_circle,
                shadows: const [Shadow(color: Colors.white)],
                color: hintColor,
                size: 25.sp,
              ),
            ),
            SpeedDialChild(
              backgroundColor: Colors.white,
              elevation: 0,
              label: "Phone",
              labelShadow: [],
              onTap: () => launchPhoneDialer(contactNumber),
              child: Icon(
                Icons.phone,
                color: Colors.blue,
                size: 25.sp,
              ),
            ),
            SpeedDialChild(
              backgroundColor: Colors.white,
              label: "Whatsapp",
              onTap: () => launchWhatsApp(contactNumber),
              elevation: 0,
              labelShadow: [],
              child: FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.green,
                size: 25.sp,
              ),
            ),
            SpeedDialChild(
              backgroundColor: Colors.white,
              label: "Logout",
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.grey.shade100,
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            print("Logout");
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChooseNumber()),
                              (route) => false,
                            );
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
              elevation: 0,
              labelShadow: [],
              child: Icon(
                Icons.logout,
                color: Colors.red,
                size: 25.sp,
              ),
            )
          ],
        ));
  }

  void _showSubmitSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Application submitted successfully!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}