import 'package:delivery_app/utlis/color_codes.dart';
import 'package:delivery_app/widgets/containerWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewDetails extends StatefulWidget {
  final String? name;
  final String phone;
  final String address;
  final String paymentStatus;
  final String price;
  final String additionalInfo;
  final String location;
  final Color orderColor;
  final String statusOrder;
  const ViewDetails(
      {super.key,
      required this.name,
      required this.phone,
      required this.address,
      required this.paymentStatus,
      required this.price,
      required this.location,
      required this.orderColor,
      required this.statusOrder,
      required this.additionalInfo});

  @override
  State<ViewDetails> createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
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
            size: 18.sp,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'View Details',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 17.sp),
        ),
      ),
      body: Column(
        children: [
          CustomContainerWidget(
            value: 'Name: ',
            text: "${widget.name}",
          ),
          CustomContainerWidget(
            value: 'Phone: ',
            text: widget.phone,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10),
            child: Container(
              height: 40.h,
              width: 350.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 10.w),
                    Text(
                      "Address: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.address,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10),
            child: Container(
              height: 40.h,
              width: 350.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10.w),
                        Text(
                          "Payment Status: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        SelectableText(
                          " ${widget.paymentStatus}  + лв${widget.price}",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10),
            child: Container(
              height: 40.h,
              width: 350.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 10.w),
                    Text(
                      "Location: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    SelectableText(
                      widget.location,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10),
            child: Container(
              height: 40.h,
              width: 350.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 10.w),
                    Text(
                      "Additional Info: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.additionalInfo,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10),
            child: Container(
              height: 40.h,
              width: 350.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 10.w),
                    Text(
                      "Order Status: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.statusOrder,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                        color: widget.orderColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
