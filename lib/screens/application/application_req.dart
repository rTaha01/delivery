import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/screens/application/viewDetails/viewDetails.dart';
import 'package:delivery_app/utlis/color_codes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/fetchNumber.dart';
import '../../controller/fetch_details.dart';

Future<List<DeliveryData>> _fetchApplicationRequests() async {
  List<DeliveryData> applicationRequests = [];
  String? phoneNumber = currentUserPhoneNumber();

  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(phoneNumber!).get();

    for (var doc in querySnapshot.docs) {
      String name = doc['name'];
      String number = doc['phone'];
      String address = doc['address'];
      String price = doc['price'];
      String paymentStatus = doc['paymentStatus'];
      String additionalInfo = doc['additionalInfo'];
      String orderNo = doc['orderNo'];
      DeliveryData deliveryData = DeliveryData(
        name: name,
        phone: number,
        address: address,
        paymentStatus: paymentStatus,
        additionalInfo: additionalInfo,
        orderNO: orderNo,
        price: price,
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

class ApplicationRequest extends StatefulWidget {
  const ApplicationRequest({super.key});

  @override
  State<ApplicationRequest> createState() => _ApplicationRequestState();
}

class _ApplicationRequestState extends State<ApplicationRequest> {
  late Future<List<DeliveryData>> _futureApplicationRequests;

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
        leading: InkWell(
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
        title: Text(
          'Application Requests',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 17.sp),
        ),
      ),
      body: FutureBuilder<List<DeliveryData>>(
        future: _futureApplicationRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                      letterSpacing: 0.5),
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
                      height: 130.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 1,
                                spreadRadius: 1,
                                offset: const Offset(1, 1))
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                "Order no:",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                    letterSpacing: 0.5),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                requestData.orderNO,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                    letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                "Name:",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                    letterSpacing: 0.5),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                requestData.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                "Phone:",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                    letterSpacing: 0.5),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                requestData.phone,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                "Address:",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                    letterSpacing: 0.5),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                requestData.address,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                    color: Colors.black,
                                    letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewDetails(
                                    name: requestData.name,
                                    additionalInfo: requestData.additionalInfo,
                                    phone: requestData.phone,
                                    address: requestData.address,
                                    price: requestData.price,
                                    paymentStatus: requestData.paymentStatus,
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
                                      fontSize: 14.sp,
                                      color: hintColor,
                                      letterSpacing: 0.5),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: hintColor,
                                  size: 13.sp,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                  // return ListTile(
                  //   title: Text(requestData.name),
                  //   subtitle: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text('Phone: ${requestData.phone}'),
                  //       Text('Address: ${requestData.address}'),
                  //       Text('Payment Status: ${requestData.paymentStatus}'),
                  //       Text('Additional Info: ${requestData.additionalInfo}'),
                  //     ],
                  //   ),
                  // );
                },
              );
            }
          }
        },
      ),
    );
  }
}
