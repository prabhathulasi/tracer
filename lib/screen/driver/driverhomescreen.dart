import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/common/connectivity.dart';
import 'package:tracer/data/model/driverjourneymodel.dart';
import 'package:tracer/data/model/loginmodel.dart';
import 'package:tracer/data/provider/driver_journey_provider.dart';
import 'package:tracer/screen/account_screen.dart';
import 'package:tracer/screen/driver/driverjourneyscreen.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/app_richtext.dart';

class DriverHomeScreenPage extends StatefulWidget {
  const DriverHomeScreenPage({super.key});

  @override
  _DriverHomeScreenPageState createState() => _DriverHomeScreenPageState();
}

class _DriverHomeScreenPageState extends State<DriverHomeScreenPage> {
  String? token, userName;
  late Response response;
  late Payload djModel;
  bool isInternet = true;
  String? acceptedJourney = "NO";
  bool btnenabled = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    super.initState();
  }

  // connectioncheck() async {
  //   ConnectivityResult connectivityResult =
  //       await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.mobile) {
  //     isInternet = true;
  //     // You are connected to a mobile network.
  //   } else if (connectivityResult == ConnectivityResult.wifi) {
  //     isInternet = true;
  //     // You are connected to a WiFi network.
  //   } else {
  //     isInternet = false;
  //     // You are not connected to any network.
  //   }
  // }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }
    log('Connection Status: $result');
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  logoutClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("status", "0");
  }

  @override
  Widget build(BuildContext context) {
    final driverJourneyProvider =
        Provider.of<DriverJourneyProvider>(context, listen: false);
    getNewJourney() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      return driverJourneyProvider.fetchDashboardData(token!);
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: const Color(0xff09313c),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: AppRichText(
              text: "TRACER JM",
              style: TextStyle(
                  fontFamily: 'RBold',
                  fontSize: 6.sp,
                  color: AppColors.colorce9),
            ),
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: _connectionStatus == ConnectivityResult.wifi ||
                            _connectionStatus == ConnectivityResult.mobile
                        ? const Icon(
                            Icons.signal_wifi_4_bar,
                            color: Color(0xffb0edff),
                            size: 26.0,
                          )
                        : const Icon(
                            Icons.signal_wifi_off,
                            color: Colors.red,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AccountScreen()),
                      );
                    },
                    child: const Icon(
                      Icons.account_circle,
                      color: Color(0xffb0edff),
                    ),
                  )),
            ],
          ),
          body: FutureBuilder(
              future: getNewJourney(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                } else if (driverJourneyProvider
                        .driverJourneyModel.p?.message ==
                    "You do not have any new journey") {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppRichText(
                        align: TextAlign.center,
                        text:
                            driverJourneyProvider.driverJourneyModel.p!.message,
                        style: TextStyle(
                            fontFamily: "RBold",
                            fontSize: 9.sp,
                            color: AppColors.color4c4),
                      ),
                    ),
                  );
                } else if (driverJourneyProvider
                        .driverJourneyModel.p?.journeyStatus1 !=
                    1) {
                  return const DriverJourneyScreenPage();
                } else {
                  var data = driverJourneyProvider.driverJourneyModel;
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: SingleChildScrollView(
                      child: Column(children: [
                        SizedBox(height: 3.8.h),
                        AppRichText(
                          text: 'Welcome ${data.p!.drvName}',
                          style: TextStyle(
                              fontFamily: "RBold",
                              fontSize: 5.sp,
                              color: AppColors.color4c4),
                        ),
                        SizedBox(
                          height: 5.8.sp,
                        ),
                        AppRichText(
                          align: TextAlign.center,
                          text: data.p!.message,
                          style: TextStyle(
                              fontFamily: "RRegular",
                              fontSize: 8.sp,
                              color: AppColors.color4c4),
                        ),
                        SizedBox(height: 6.8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.truck,
                              color: AppColors.color4c4,
                              size: 4.sp,
                            ),
                            SizedBox(width: 1.9.w),
                            AppRichText(
                              text: data.p!.vehName,
                              style: TextStyle(
                                  fontFamily: "RBold",
                                  fontSize: 5.sp,
                                  color: AppColors.color4c4),
                            )
                          ],
                        ),
                        AppRichText(
                          text: data.p!.vehType,
                          style: TextStyle(
                              fontFamily: "RRegular",
                              fontSize: 4.sp,
                              color: AppColors.color4c4),
                        ),
                        AppRichText(
                          text: "Capacity: ${data.p!.capacity}",
                          style: TextStyle(
                              fontFamily: "RBold",
                              fontSize: 3.sp,
                              color: AppColors.color4c4),
                        ),
                        SizedBox(height: 10.3.h),
                        AppRichText(
                          align: TextAlign.center,
                          text: data.p!.startLoc,
                          style: TextStyle(
                              fontFamily: "RBold",
                              fontSize: 9.sp,
                              color: AppColors.color4c4),
                        ),
                        AppRichText(
                          text: DateFormat('dd/MM/yyyy HH:mm a')
                              .format(DateTime.parse(data.p!.startTimeStr!))
                              .toString(),
                          style: TextStyle(
                              fontFamily: "RBold",
                              fontSize: 4.sp,
                              color: AppColors.color4c4),
                        ),
                        SizedBox(
                          height: 2.5.h,
                        ),
                        Icon(
                          FontAwesomeIcons.arrowDown,
                          size: 20.sp,
                          color: AppColors.color4c4,
                        ),
                        SizedBox(
                          height: 6.3.h,
                        ),
                        AppRichText(
                          align: TextAlign.center,
                          text: data.p!.endLoc,
                          style: TextStyle(
                              fontFamily: "RBold",
                              fontSize: 9.sp,
                              color: AppColors.color4c4),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: 30.w,
                                height: 10.h,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        const MaterialStatePropertyAll<Color>(
                                            Color(0xFF0f5164)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(57.sp)),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();

                                    var token = prefs.getString('token');
                                    await driverJourneyProvider
                                        .acceptRejectAction("2", token!);
                                    if (context.mounted) {
                                      Navigator.pushNamed(
                                          context, '/driverjourneyscreen');
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.solidCircleCheck,
                                        size: 5.sp,
                                        color: const Color(0xFFb0edff),
                                        // color: HexColor("#6acce9"),
                                      ),
                                      Text("Accept",
                                          style: TextStyle(
                                              fontFamily: "RBold",
                                              fontSize: 4.sp,
                                              color: const Color(0xFFb0edff))),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 30.w,
                                height: 10.h,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        const MaterialStatePropertyAll<Color>(
                                            Color(0xFF0f5164)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(57.5.sp)),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();

                                    var token = prefs.getString('token');
                                    await driverJourneyProvider
                                        .acceptRejectAction("3", token!);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: const [
                                      Icon(
                                        FontAwesomeIcons.solidCircleXmark,
                                        size: 30,
                                        color: Color(0xFFb0edff),
                                      ),
                                      Text("Reject",
                                          style: TextStyle(
                                              fontFamily: "RBold",
                                              fontSize: 16,
                                              color: Color(0xFFb0edff))),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                    ),
                  );
                }
              })),
    );
  }
}
