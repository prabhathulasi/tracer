import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/app_richtext.dart';

class ListItem extends StatelessWidget {
  final String indexLabel;
  final String locationLabel;
  final String buttonLabel;
  final String subLabel;
  final String thirdLabel;
  final int journeyStatus;
  final int journeyStatus1;
  final VoidCallback onPressed;

  ListItem(
      {required this.indexLabel,
      required this.locationLabel,
      required this.buttonLabel,
      required this.onPressed,
      required this.subLabel,
      required this.thirdLabel,
      required this.journeyStatus,
      required this.journeyStatus1});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 7.5.h,
          width: 7.5.w,
          decoration: const BoxDecoration(
            color: AppColors.color4c4,
            shape: BoxShape.circle,
          ),
          child: Center(
              child: AppRichText(
            text: indexLabel,
            style: TextStyle(
                fontFamily: "RBold",
                fontSize: 6.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF09323f)),
          )),
        ),
        SizedBox(width: 5.3.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppRichText(
                  text: locationLabel,
                  style: TextStyle(
                      fontFamily: "RBold",
                      fontSize: 6.sp,
                      color: AppColors.color4c4),
                ),
                AppRichText(
                  text: subLabel,
                  style: TextStyle(
                      fontFamily: "RBold",
                      fontSize: 3.5.sp,
                      color: AppColors.color4c4),
                ),
                AppRichText(
                  text: thirdLabel,
                  style: TextStyle(
                      fontFamily: "RRegular",
                      fontSize: 3.sp,
                      color: AppColors.color4c4),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          width: 4.8.w,
        ),
        ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xff0f5164)),
              foregroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xffb0edff)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.sp),
                ),
              ),
            ),
            child: AppRichText(
              text: buttonLabel,
              style: TextStyle(fontFamily: "RBold", fontSize: 4.sp),
            )),
        SizedBox(width: 7.3.w),
        journeyStatus == 1
            ? Icon(
                FontAwesomeIcons.solidCircleCheck,
                color: AppColors.colorb7b,
                size: 5.sp,
              )
            : const Text(""),
      ],
    );
  }
}
