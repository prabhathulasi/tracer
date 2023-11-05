import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/common/connectivity.dart';
import 'package:tracer/data/model/dashboardmodel.dart';
import 'package:tracer/screen/createjourneyscreen.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/customAppBar.dart';
import 'package:tracer/widget/mytextstyle.dart';

class DashboardScreenPage extends StatefulWidget {
  const DashboardScreenPage({super.key});

  @override
  _DashboardScreenPageState createState() => _DashboardScreenPageState();
}

class _DashboardScreenPageState extends State<DashboardScreenPage> {
  String? token;
  late Response response;
  String? onGoingVal = "0";
  String? completedVal = "0";
  String? vehiclesVal = "0";
  String? driversVal = "0";
  bool isInternet = true;
  @override
  void initState() {
    super.initState();
    connectioncheck();
    getSharedPrefenceVal();
  }

  connectioncheck() async {
    if (await ConnectivityCheck().isInternetAvailable()) {
      isInternet = true;
    } else {
      isInternet = false;
    }
  }

  getSharedPrefenceVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    fetchDashboardData();
  }

  void fetchDashboardData() async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = TracerApis.login + "?controller=jm_manager";

    Map<String, dynamic> data = {};
    data.addAll({'c': "1"});

    data.addAll({'t': "0"});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    response = await dio.post(url, queryParameters: data);
    print(response.data.toString());
    var dataVal =
        (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

    if (dataVal['s'] == 0) {
      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);
      List<DashboardModel> jsonList = (jsonMap['p']['db_arr'] as List<dynamic>)
          .map((e) => DashboardModel.fromJson(e))
          .toList();
      setState(() {
        onGoingVal = jsonList[0].value.toString();
        completedVal = jsonList[1].value.toString();
        vehiclesVal = jsonList[2].value.toString();
        driversVal = jsonList[3].value.toString();
      });

      //print(jsonList.toString());
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Alert'),
          content: const Text("Failed to Load. Please try again."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    progress?.dismiss();
  }

  logoutClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("status", "0");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xff09313c),
        appBar: AppBar(
          backgroundColor: const Color(0xff052028),
          automaticallyImplyLeading: false,
          title: const Text("TRACER JM",
              style: TextStyle(
                  fontFamily: 'RBold', fontSize: 24, color: Color(0xffb0edff))),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: isInternet
                      ? const Icon(
                          Icons.signal_wifi_4_bar,
                          color: Color(0xffb0edff),
                          size: 26.0,
                        )
                      : const Icon(
                          Icons.signal_wifi_off,
                          color: Color(0xffb0edff),
                          size: 26.0,
                        ),
                )),
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.help, color: Color(0xffb0edff)),
                )),
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                        title: const Text("CONFIRMATION"),
                        content: const Text("ARE YOU SURE TO LOGOUT?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              logoutClear();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text('YES'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context, 'OK');
                            },
                            child: const Text('NO'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.account_circle,
                    color: Color(0xffb0edff),
                  ),
                )),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 6.3.h, left: 4.3.w, right: 4.3.w),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      color: const Color(0xFF0f5164),
                      child: SizedBox(
                        height: 22.5.h,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.5.sp),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                    text: TextSpan(
                                  text: onGoingVal.toString(),
                                  style: TextStyle(
                                      fontFamily: 'RBold',
                                      fontSize: 9.sp,
                                      color: AppColors.color4c4),
                                )),
                                Divider(
                                  color: AppColors.color4c4,
                                  height: 0.3.h,
                                ),
                                SizedBox(
                                  height: 1.3.h,
                                ),
                                RichText(
                                    text: TextSpan(
                                        text: "Ongoing Journeys",
                                        style: TextStyle(
                                            fontFamily: 'RBold',
                                            fontSize: 4.sp,
                                            color: AppColors.color4c4))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.3.w,
                  ),
                  Expanded(
                    child: Card(
                      color: const Color(0xFF0f5164),
                      child: SizedBox(
                        height: 22.5.h,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                  text: TextSpan(
                                text: completedVal.toString(),
                                style: TextStyle(
                                    fontFamily: 'RBold',
                                    fontSize: 9.sp,
                                    color: AppColors.color4c4),
                              )),
                              Divider(
                                color: AppColors.color4c4,
                                height: 0.3.h,
                              ),
                              SizedBox(
                                height: 1.3.h,
                              ),
                              RichText(
                                  text: TextSpan(
                                      text: "Completed Journeys",
                                      style: TextStyle(
                                          fontFamily: 'RBold',
                                          fontSize: 4.sp,
                                          color: AppColors.color4c4))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Padding(
              padding: EdgeInsets.only(left: 4.3.w, right: 4.3.w),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      color: const Color(0xFF0f5164),
                      child: SizedBox(
                        height: 22.5.h,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                  text: TextSpan(
                                text: vehiclesVal.toString(),
                                style: TextStyle(
                                    fontFamily: 'RBold',
                                    fontSize: 9.sp,
                                    color: AppColors.color4c4),
                              )),
                              Divider(
                                color: AppColors.color4c4,
                                height: 0.3.h,
                              ),
                              SizedBox(
                                height: 1.3.h,
                              ),
                              RichText(
                                  text: TextSpan(
                                      text: "Vehicles Available",
                                      style: TextStyle(
                                          fontFamily: 'RBold',
                                          fontSize: 4.sp,
                                          color: AppColors.color4c4))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.3.w,
                  ),
                  Expanded(
                    child: Card(
                      color: const Color(0xFF0f5164),
                      child: SizedBox(
                        height: 22.5.h,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                  text: TextSpan(
                                text: driversVal.toString(),
                                style: TextStyle(
                                    fontFamily: 'RBold',
                                    fontSize: 9.sp,
                                    color: AppColors.color4c4),
                              )),
                              Divider(
                                color: AppColors.color4c4,
                                height: 0.3.h,
                              ),
                              SizedBox(
                                height: 1.3.h,
                              ),
                              RichText(
                                  text: TextSpan(
                                      text: "Drivers Available",
                                      style: TextStyle(
                                          fontFamily: 'RBold',
                                          fontSize: 4.sp,
                                          color: AppColors.color4c4))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 5.8.h,
            ),
            Padding(
              padding: EdgeInsets.only(left: 4.3.w, right: 4.3.w),
              child: Divider(
                color: AppColors.color4c4,
                height: 0.5.h,
              ),
            ),
            SizedBox(
              height: 11.h,
            ),
            SizedBox(
              height: 10.h,
              width: 34.8.w,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: const MaterialStatePropertyAll<Color>(
                        Color(0xFF0f5164)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.sp)),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProgressHUD(
                                child: CreateJourneyScreenPage(),
                              )),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                        text: "Create Journey",
                        style: TextStyle(
                            fontFamily: "RBold",
                            fontSize: 4.sp,
                            color: const Color(0xFFb0edff))),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
