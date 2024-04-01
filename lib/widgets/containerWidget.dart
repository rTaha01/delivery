import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomContainerWidget extends StatefulWidget {
  final String? text;
  final String? value;

  const CustomContainerWidget({super.key, required this.text, required this.value});

  @override
  _CustomContainerWidgetState createState() => _CustomContainerWidgetState();
}

class _CustomContainerWidgetState extends State<CustomContainerWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10),
      child: Container(
        height: 40.h,
        width: 350.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 10.w,
            ),
            Text(
              widget.value!,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11.sp,
                  color: Colors.black,
                  letterSpacing: 0.5),
            ),
            SizedBox(
              width: 4.w,
            ),
            Text(
              widget.text!,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  color: Colors.black,
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
