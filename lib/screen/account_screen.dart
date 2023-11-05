import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/screen/webview_screen.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/app_richtext.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

logoutClear() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("status", "0");
}

class _AccountScreenState extends State<AccountScreen> {
  String? userName;
  getUserName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = sharedPreferences.getString("username");
    setState(() {
      userName = data;
    });
  }

  @override
  void initState() {
    getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.color23f,
      appBar: AppBar(
        backgroundColor: AppColors.color028,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.close,
            color: AppColors.colorce9,
          ),
        ),
        title: AppRichText(
          text: "Account",
          style: TextStyle(
              color: AppColors.colorce9, fontSize: 5.sp, fontFamily: "RMedium"),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.sp),
        child: Column(
          children: [
            Card(
              child: Container(
                  color: AppColors.color164,
                  height: 12.5.h,
                  width: size.width,
                  child: Center(
                    child: ListTile(
                      title: AppRichText(
                        text: "Welcome $userName",
                        style: TextStyle(
                            fontFamily: "RMedium",
                            fontSize: 3.5.sp,
                            color: AppColors.color4c4),
                      ),
                    ),
                  )),
            ),
            SizedBox(
              height: 3.8.h,
            ),
            Card(
                child: Container(
              color: AppColors.color164,
              width: size.width,
              height: 38.h,
              child: Padding(
                padding: EdgeInsets.only(left: 3.8.w, top: 2.5.h, right: 11.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppRichText(
                      text: "About",
                      style: TextStyle(
                          fontFamily: "RMedium",
                          fontSize: 4.sp,
                          color: AppColors.color4c4),
                    ),
                    SizedBox(
                      height: 2.5.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppRichText(
                          text: "Version Number",
                          style: TextStyle(
                              fontFamily: "RRegular",
                              fontSize: 4.sp,
                              color: AppColors.color4c4),
                        ),
                        AppRichText(
                          text: "1.0.0",
                          style: TextStyle(
                              fontFamily: "RRegular",
                              fontSize: 4.sp,
                              color: AppColors.color4c4),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2.5.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppRichText(
                          text: "Build Date",
                          style: TextStyle(
                              fontFamily: "RRegular",
                              fontSize: 4.sp,
                              color: AppColors.color4c4),
                        ),
                        AppRichText(
                          text: "25/11/20",
                          style: TextStyle(
                              fontFamily: "RRegular",
                              fontSize: 4.sp,
                              color: AppColors.color4c4),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2.5.h,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrivacyScreen(
                                    title: "Privacy Policy",
                                    url:
                                        "http://tracer.co.in/Mobappprivacy.aspx",
                                  )),
                        );
                      },
                      child: AppRichText(
                        text: "Privacy Policy",
                        style: TextStyle(
                            fontFamily: "RRegular",
                            fontSize: 4.sp,
                            color: AppColors.colordff),
                      ),
                    ),
                    SizedBox(
                      height: 2.5.h,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrivacyScreen(
                                    title: "Tracer",
                                    url: "http://tracer.co.in/",
                                  )),
                        );
                      },
                      child: AppRichText(
                        text: "For more details visit our web site",
                        style: TextStyle(
                            fontFamily: "RRegular",
                            fontSize: 4.sp,
                            color: AppColors.colordff),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            SizedBox(
              height: 3.8.h,
            ),
            InkWell(
              onTap: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    backgroundColor: AppColors.color164,
                    title: const Text("CONFIRMATION",
                        style: TextStyle(color: Colors.white)),
                    content: const Text("ARE YOU SURE TO LOGOUT?",
                        style: TextStyle(color: Colors.white)),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          logoutClear();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => const LoginScreen()),
                          // );
                        },
                        child: const Text(
                          'YES',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context, 'OK');
                        },
                        child: const Text('NO',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              child: Card(
                child: Container(
                    color: AppColors.color164,
                    height: 12.5.h,
                    width: size.width,
                    child: Center(
                      child: ListTile(
                        title: AppRichText(
                          text: "Logout",
                          style: TextStyle(
                              fontFamily: "RRegular",
                              fontSize: 3.5.sp,
                              color: AppColors.colordff),
                        ),
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
