import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracer/themes/app_colors.dart';

class InspectionListItem extends StatelessWidget {
  final String indexLabel;
  final String? imagePath;

  final bool imgUploaded;
  final bool alreadyUploaded;
  final VoidCallback onViewPressed;
  final VoidCallback onUploadPressed;
  final VoidCallback onDeletePressed;

  InspectionListItem({
    required this.indexLabel,
    required this.imagePath,
    required this.alreadyUploaded,
    required this.onViewPressed,
    required this.imgUploaded,
    required this.onUploadPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5.w, top: 5.3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            indexLabel,
            style: const TextStyle(
                fontFamily: "RBold", fontSize: 16, color: AppColors.color4c4),
          ),
          SizedBox(width: 6.3.w),
          alreadyUploaded == true
              ? FadeInImage.assetNetwork(
                  width: 10.w,
                  height: 15.h,
                  placeholder: "assets/images/noimage.jpeg",
                  image: imagePath!)
              : Image.file(
                  File(imagePath!),
                  width: 10.w,
                  height: 15.h,
                  fit: BoxFit.cover,
                ),
          SizedBox(
            width: 21.8.w,
          ),
          Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: GestureDetector(
                onTap: onViewPressed,
                child: Icon(
                  FontAwesomeIcons.eye,
                  color: Color(0xffb0edff),
                  size: 5.sp,
                )),
          ),
          SizedBox(width: 9.5.w),
          alreadyUploaded != false
              ? Padding(
                  padding: EdgeInsets.only(top: 3.h),
                  child: GestureDetector(
                      onTap: onDeletePressed,
                      child: Icon(
                        Icons.delete,
                        color: Color(0xffb0edff),
                        size: 5.sp,
                      )),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 3.h),
                  child: GestureDetector(
                      onTap: onUploadPressed,
                      child: Icon(
                        FontAwesomeIcons.upload,
                        color: Color(0xffb0edff),
                        size: 5.sp,
                      )),
                ),
          SizedBox(width: 9.5.w),
          alreadyUploaded == true
              ? Padding(
                  padding: EdgeInsets.only(top: 3.h),
                  child: GestureDetector(
                      child: Icon(
                    FontAwesomeIcons.solidCircleCheck,
                    color: Colors.green,
                    size: 5.sp,
                  )),
                )
              : Container(),
        ],
      ),
    );
  }
}
