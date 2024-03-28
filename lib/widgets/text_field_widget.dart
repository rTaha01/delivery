import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utlis/color_codes.dart';

class CommonField {
  static customField(keyboardType, controller, hintText, icon,) {
    return SizedBox(
      height: 40.h,
      child: Padding(
        padding: EdgeInsets.only(left: 10.0.w, right: 10.w,),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: Colors.black,
          cursorHeight: 13.h,
          cursorWidth: 1.5.w,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.bottom,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 0.6),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              prefixIcon: icon,
              hintText: hintText,
              hintStyle: TextStyle(
                color: hintColor,
                fontSize: 14.sp,
              )),
          style: TextStyle(fontSize: 13.0.sp, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
