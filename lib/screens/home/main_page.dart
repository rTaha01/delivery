import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/screens/profile_info/profile_info.dart';
import 'package:delivery_app/utlis/common_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marquee/marquee.dart';
import '../../auth/chooseNumber.dart';
import '../../controller/contact_controller.dart';
import '../../controller/fetchNumber.dart';
import '../../utlis/color_codes.dart';
import '../../widgets/loader.dart';
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
TextEditingController additionalInfo = TextEditingController();
String number = "+92";
bool? _isPay = false;
final firestore = FirebaseFirestore.instance;

class _MainScreenState extends State<MainScreen> {
  String generateOrderNumber() {
    int randomInt = Random().nextInt(900000) +
        100000; // Random integer between 100000 and 999999
    return "#$randomInt";
  }

  Future<void> _saveApplication(String name, String phone, String address,
      isPay, String additionInformation, context) async {
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
    } else if (isPay == null) {
      CommonWidget.toastMessage("Select Price Status");
    } else if (additionInformation.isEmpty || additionInformation == "") {
      CommonWidget.toastMessage("Add Some additional information");
    } else {
      Map<String, dynamic> requestData = {
        'orderNo': orderNumber,
        'name': name,
        'number': number + phone,
        'address': address,
        'paymentStatus': isPay != null
            ? (isPay ? 'төлөнгөн' : 'төлөнбөгөн (демейки)')
            : 'UNKNOWN',
        'additionalInfo': additionalInfo.text,
        'orderStatus': 'Processing',
        'colorStatus': '0xffffab40',
        'location': 'n',
        "date": DateTime.now(),
      };
      try {
        CommonWidget.loader(context);
        await FirebaseFirestore.instance
            .collection("userRequest")
            .doc(phoneNumber!)
            .collection("applicationRequest")
            .doc(orderNumber)
            .set(requestData);

        Navigator.pop(context);
        _showSubmitSuccessDialog();
        print("Application request saved with order number: $orderNumber");
        setState(() {
          nameController.clear();
          numberController.clear();
          addressController.clear();
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

  Stream<List<Map<String, dynamic>>> fetchBanners() {
    try {
      return FirebaseFirestore.instance
          .collection('banners')
          .snapshots()
          .map((querySnapshot) =>
          querySnapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error fetching banners: $e');
      return Stream.value([]); // Return an empty stream on error
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fetchBanners(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'No  Banner',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      );
                    } else {
                      final banners = snapshot.data!;
                      return Container(
                        height: 100.h,
                        width: 360.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              offset: const Offset(4, 3),
                            )
                          ],
                        ),
                        child: CarouselSlider(
                          options: CarouselOptions(
                              scrollPhysics: const BouncingScrollPhysics(),
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 3),
                              viewportFraction: 1),
                          items: banners.map((banner) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                banner['imageUrl'],
                                width: 350.w,
                                fit: BoxFit.fill,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 10.h,
                ),
                FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('ticker')
                      .orderBy('timestamp', descending: true)
                      .limit(1)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Text('No ticker message found');
                    } else {
                      final tickerMessage =
                          snapshot.data!.docs.first.get('message');
                      return SizedBox(
                        height: 15.h,
                        child: Marquee(
                          text: '$tickerMessage       ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      );
                    }
                  },
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
                        Padding(
                          padding: EdgeInsets.only(left: 10.0.w, right: 10.w),
                          child: Container(
                            height: 38.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.black, width: 0.6),
                            ),
                            margin: EdgeInsets.only(top: 10.h),
                            child: Row(
                              children: [
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Icon(
                                    Icons.attach_money,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  _isPay == null
                                      ? "ОПЛАТА"
                                      : _isPay!
                                          ? "төлөнгөн"
                                          : "төлөнбөгөн (демейки)",
                                  style: TextStyle(
                                      color: hintColor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
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
                              setState(() {
                                _isPay =
                                    true; // Set the selected payment option to true (төлөнгөн)
                              });
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
                                        _isPay = value;
                                      });
                                    },
                                  ),
                                  const Text(
                                    "ОПЛАЧЕН",
                                    style: TextStyle(
                                        fontSize: 15,
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
                              setState(() {
                                _isPay =
                                    false; // Set the selected payment option to false (төлөнбөгөн)
                              });
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
                                    value: false,
                                    activeColor: Colors.red,
                                    groupValue: _isPay,
                                    onChanged: (value) {
                                      setState(() {
                                        _isPay = value;
                                      });
                                    },
                                  ),
                                  const Text(
                                    "НЕ ОПЛАЧЕН (наличные курьеру)",
                                    style: TextStyle(
                                        fontSize: 15,
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
                                prefixIcon: GestureDetector(
                                  onTap: () {
                                    _showSubmitSuccessDialog();
                                  },
                                  child: const Icon(
                                    Icons.info,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                )),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
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
                              _isPay,
                              additionalInfo.text,
                              context,
                            );
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
                await showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.grey.shade50,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  builder: (context) {
                    return SizedBox(
                      height: 250,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 30.0,
                            ),
                            child: Text(
                              "Are you sure you want to logout?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 30.0,
                            ),
                            child: Text(
                              "You will be logged out of your account.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: GestureDetector(
                              onTap: () async {
                                await FirebaseAuth.instance.signOut();
                                print("Logout");
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChooseNumber(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: Container(
                                height: 40.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: hintColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Icon(
                                      Icons.logout,
                                      color: hintColor,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    const Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context, "Cancel");
                              },
                              child: Container(
                                height: 40.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          backgroundColor: Colors.white,
          title: Image.asset(
            "assets/images/congrats.gif",
            height: 100,
          ),
          content: const Text(
            "Your Application has been submitted successfully!\nCheck the order status click on the МОИ ЗАЯВКИ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
