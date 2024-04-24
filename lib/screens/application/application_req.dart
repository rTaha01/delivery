import 'package:delivery_app/screens/application/viewDetails/viewDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../controller/fetchNumber.dart';
import '../../utlis/color_codes.dart';
import '../../widgets/loader.dart';

class ApplicationRequest extends StatefulWidget {
  const ApplicationRequest({super.key});

  @override
  State<ApplicationRequest> createState() => _ApplicationRequestState();
}

class DeliveryData {
  final String name;
  final String phoneNumber;
  final String address;
  final String paymentStatus;
  final String additionalInfo;
  final String orderNO;
  final Color color;
  final String status;

  DeliveryData({
    required this.orderNO,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.paymentStatus,
    required this.color,
    required this.status,
    required this.additionalInfo,
  });
}

class _ApplicationRequestState extends State<ApplicationRequest> {
  late Future<List<DeliveryData>> _futureApplicationRequests;

  Future<List<DeliveryData>> _fetchApplicationRequests() async {
    List<DeliveryData> applicationRequests = [];
    String? phoneNumber = currentUserPhoneNumber();

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("userRequest")
          .doc(phoneNumber!)
          .collection("applicationRequest")
          .get();
      for (var doc in querySnapshot.docs) {
        DocumentSnapshot data = await doc.reference.get();
        String name = data['name'] ?? '';
        String number = data['number'] ?? '';
        String address = data['address'] ?? '';
        String paymentStatus = data['paymentStatus'] ?? '';
        String additionalInfo = data['additionalInfo'] ?? '';
        String orderNo = data['orderNo'] ?? '';
        String colorCode = data['colorStatus'] ?? '';
        Color color = colorCode.isNotEmpty
            ? Color(int.parse('0xFF$colorCode'))
            : Colors.transparent;

        String statusCode = data['orderStatus'] ?? '';

        DeliveryData deliveryData = DeliveryData(
          name: name,
          phoneNumber: number,
          address: address,
          paymentStatus: paymentStatus,
          additionalInfo: additionalInfo,
          orderNO: orderNo,
          color: color, // Assign Color object directly
          status: statusCode,
        );
        applicationRequests.add(deliveryData);
      }

      if (querySnapshot.docs.isEmpty) {
        print('No application requests found for $phoneNumber');
      }
    } catch (e) {
      print('Error fetching application requests: $e');
    }

    return applicationRequests;
  }

  @override
  void initState() {
    super.initState();
    _futureApplicationRequests = _fetchApplicationRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 15.sp,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Application Requests',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17.sp,
          ),
        ),
      ),
      body: FutureBuilder<List<DeliveryData>>(
        future: _futureApplicationRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loader();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<DeliveryData> applicationRequests = snapshot.data ?? [];

            if (applicationRequests.isEmpty) {
              return Center(
                child: Text(
                  'No application',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: applicationRequests.length,
                itemBuilder: (context, index) {
                  DeliveryData requestData = applicationRequests[index];
                  return Padding(
                    padding:
                        EdgeInsets.only(left: 10.0.w, right: 10.0.w, top: 5.h),
                    child: Container(
                      height: 135.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 1,
                            spreadRadius: 1,
                            offset: const Offset(1, 1),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              SizedBox(width: 10.w),
                              Text(
                                "Order no:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                requestData.orderNO,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              SizedBox(width: 10.w),
                              Text(
                                "Name:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                requestData.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              SizedBox(width: 10.w),
                              Text(
                                "Phone:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                requestData.phoneNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              SizedBox(width: 10.w),
                              Text(
                                "Status:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                requestData.status,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                  color: Colors.orangeAccent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewDetails(
                                    name: requestData.name,
                                    additionalInfo: requestData.additionalInfo,
                                    phone: requestData.phoneNumber,
                                    address: requestData.address,
                                    paymentStatus: requestData.paymentStatus,
                                    orderColor: requestData.color,
                                    statusOrder: requestData.status,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "View details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                    color: hintColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: hintColor,
                                  size: 13.sp,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
