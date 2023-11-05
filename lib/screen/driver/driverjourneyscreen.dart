import 'dart:developer';

//import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/data/model/driverjourneymodel.dart';
import 'package:tracer/screen/driver/driverhomescreen.dart';
import 'package:tracer/screen/drivervehicleinspscreen.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/app_richtext.dart';
import 'package:tracer/widget/dottedline.dart';
import 'package:tracer/widget/listitem.dart';
import 'package:tracer/widget/mytextstyle.dart';
import 'package:intl/intl.dart';

class DriverJourneyScreenPage extends StatefulWidget {
  const DriverJourneyScreenPage({super.key});

  @override
  _DriverJourneyScreenPageState createState() =>
      _DriverJourneyScreenPageState();
}

class _DriverJourneyScreenPageState extends State<DriverJourneyScreenPage> {
  var connectivityResult =
      ConnectivityResult.none; // Default to no connectivity
  String? token;
  late Response response;
  late Payload djModel;
  bool isInternet = true;
  List<DriverJourney> djList = [];
  String startDateTime = "";
  String duration = "";
  String etaTime = "";
  String distance = "";
  String journeyid = "";
  int countValue = 0;
  final TextEditingController _controller = TextEditingController();
  int inspectionDone = 0;
  @override
  void initState() {
    super.initState();
    djModel = Payload();

    getSharedPrefenceVal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedPrefenceVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    fetchDashboardData();
  }

  convertepoctime(int epochTime) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    int hours = dateTime.hour;
    int minutes = dateTime.minute;
    String formattedTime = "$hours hrs $minutes mins";
    return formattedTime;
  }

  convertminstohrs(int mins) {
    int hours = (mins / 60).floor();
    int remainingMinutes = mins % 60;
    String formattedTime = "$hours hrs $remainingMinutes mins";
    return formattedTime;
  }

  epoctostartdatetime(int startepoc) {
    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(startepoc * 1000);

    String startDateString = DateFormat('dd/MM/yyyy hh:mm a').format(startDate);

    String resultime = startDateString;

    return resultime;
  }

  epoctoenddatetime(int endepoc) {
    DateTime endDate = DateTime.fromMillisecondsSinceEpoch(endepoc);

    String endDateString = DateFormat('hh:mm a').format(endDate);

    String resultime = endDateString;

    return resultime;
  }

  String formatDistance(int distanceInMeters) {
    final distanceInKilometers = distanceInMeters / 1000.0;
    return '${distanceInKilometers.toStringAsFixed(1)} km';
  }

  void fetchDashboardData() async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = TracerApis.login + "?controller=jm_driver";

    Map<String, dynamic> data = {};
    data.addAll({'c': "1"});

    //data.addAll({'t': "0"});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    response = await dio.post(url, queryParameters: data);
    log(response.data.toString());

    // Map<String, dynamic> json = jsonDecode(response.data.toString());
    // DriverJourneyModel djModel = DriverJourneyModel.fromJson(json);

    //print(djModel.p.message);

    var dataVal =
        (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

    if (dataVal['s'] == 0) {
      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);
      Map<String, dynamic> jsonList = jsonMap['p'] as Map<String, dynamic>;

      setState(() {
        djList.clear();
        djModel = Payload();
        djModel = Payload.fromJson(jsonList);
        journeyid = djModel.journeyId.toString();
        startDateTime = epoctostartdatetime(djModel.startTimeEpoc);
        duration = convertminstohrs(djModel.journeyDurMin);
        etaTime = epoctoenddatetime(djModel.journeyEtaEpoc);
        distance = formatDistance(djModel.journeyDistMeters);
        DriverJourney djouyModel = new DriverJourney();
        djouyModel.type = 0;
        djouyModel.loc = "Vehicle Inspection";
        djList.add(djouyModel);
        djList.addAll(djModel.pointsArr);
      });

      print(djModel.pointsArr);
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

  void showpopup(int seq, String actionStr) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 30.2.h,
            width: 62.5.w,
            color: AppColors.color164,
            child: Column(
              children: [
                SizedBox(
                  height: 5.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppRichText(
                        text: 'Passenger Count',
                        style: TextStyle(
                            fontFamily: "RRegular",
                            fontSize: 4.sp,
                            color: Color(0xFFb0edff))),
                    SizedBox(
                      width: 2.8.w,
                    ),
                    Container(
                      width: 11.w,
                      height: 5.h,
                      color: AppColors.color028,
                      padding: EdgeInsets.only(left: 1.w, top: 2.h),
                      child: TextFormField(
                        controller: _controller,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2),
                        ],
                        style: const TextStyle(color: AppColors.color0cb),
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: const MaterialStatePropertyAll<Color>(
                            AppColors.color23f),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(57.5.sp)),
                          ),
                        ),
                      ),
                      onPressed: () {
                        _controller.clear();
                        Navigator.pop(context);
                      },
                      child: AppRichText(
                        text: "Cancel",
                        style: TextStyle(
                            fontFamily: "RBold",
                            fontSize: 4.sp,
                            color: const Color(0xFFb0edff)),
                      ),
                    ),
                    SizedBox(
                      width: 3.5.w,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: const MaterialStatePropertyAll<Color>(
                            AppColors.color23f),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(57.5.sp)),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (int.parse(_controller.text) > djModel.capacity) {
                          Fluttertoast.showToast(
                              msg: 'Passenger count cannot more than capacity',
                              gravity: ToastGravity.CENTER,
                              toastLength: Toast.LENGTH_LONG);
                        } else {
                          updateStatus(seq, actionStr);
                          Navigator.of(context).pop();
                        }
                      },
                      child: AppRichText(
                        text: "Save",
                        style: TextStyle(
                            fontFamily: "RBold",
                            fontSize: 4.sp,
                            color: const Color(0xFFb0edff)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void updateStatus(int seq, String actionStr) async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = "${TracerApis.login}?controller=jm_driver";

    Map<String, dynamic> data = {};
    data.addAll({'c': "6"});

    data.addAll({'p[journey_id]': djModel.journeyId});

    data.addAll({'p[point_seq]': seq});
    data.addAll({'p[action]': actionStr});
    log(seq.toString());
    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    response = await dio.post(url, queryParameters: data);
    print(response.data.toString());

    var dataVal =
        (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

    if (dataVal['s'] == 0) {
      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);
      Map<String, dynamic> jsonList = jsonMap['p'] as Map<String, dynamic>;

      setState(() {
        //print(jsonList);

        Fluttertoast.showToast(
            msg: 'Register Successfully',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG);
      });
      if (actionStr == '14') {
        //Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProgressHUD(child: const DriverHomeScreenPage()),
          ),
        );
      } else {
        fetchDashboardData();
      }
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Alert'),
          content: const Text("Failed to Save. Please try again."),
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

  void updateSOS() async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = TracerApis.login + "?controller=jm_driver_dev";

    Map<String, dynamic> data = {};
    data.addAll({'c': "7"});

    data.addAll({'p[journey_id]': djModel.journeyId});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    response = await dio.post(url, queryParameters: data);
    print(response.data.toString());

    var dataVal =
        (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

    if (dataVal['s'] == 0) {
      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);
      Map<String, dynamic> jsonList = jsonMap['p'] as Map<String, dynamic>;

      setState(() {
        //print(jsonList);
        Fluttertoast.showToast(
            msg: 'Your Request is registered Successfully',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG);
      });
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Alert'),
          content: const Text("Failed to Save. Please try again."),
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

  @override
  Widget build(BuildContext context) {
    // Check the connectivity result and change the app icon accordingly

    return Scaffold(
        backgroundColor: const Color(0xff09313c),
        body: Container(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(children: [
            SizedBox(height: 3.8.h),
            AppRichText(
              text: 'Welcome ${djModel.drvName}',
              style: TextStyle(
                  fontFamily: "RRegular",
                  fontSize: 3.5.sp,
                  color: AppColors.color4c4),
            ),
            SizedBox(height: 2.5.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.truck,
                  weight: 3.9.sp,
                  color: AppColors.color4c4,
                ),
                SizedBox(width: 1.9.w),
                AppRichText(
                  text: djModel.vehName,
                  style: TextStyle(
                      fontFamily: "RBold",
                      fontSize: 5.sp,
                      color: AppColors.color4c4),
                )
              ],
            ),
            AppRichText(
              text: djModel.vehType,
              style: TextStyle(
                  fontFamily: "RRegular",
                  fontSize: 4.sp,
                  color: AppColors.color4c4),
            ),
            AppRichText(
              text: "Capacity: ${djModel.capacity}",
              style: TextStyle(
                  fontFamily: "RBold",
                  fontSize: 3.sp,
                  color: AppColors.color4c4),
            ),
            SizedBox(height: 9.3.h),
            (djModel.pointsArr.isNotEmpty)
                ? Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: djList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = djList[index];
                        switch (item.type) {
                          case 1:
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ListItem(
                                  indexLabel: (index + 1).toString(),
                                  locationLabel: item.loc,
                                  buttonLabel: 'Start',
                                  subLabel: startDateTime,
                                  journeyStatus: item.sts,
                                  journeyStatus1: djModel.journey_status1,
                                  thirdLabel: '',
                                  onPressed: () {
                                    if (item.sts == 1) {
                                      Fluttertoast.showToast(
                                          msg: "Journey Already Started");
                                    } else if (djModel.vehInspectionStatus ==
                                        0) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Vehicle Inspection Not Completed");
                                    } else {
                                      showpopup(item.seq, '13');
                                    }
                                  },
                                ),
                                const DottedLine(
                                  height: 50,
                                  color: Colors.grey,
                                ),
                              ],
                            );
                          case 2:
                            return Column(
                              children: [
                                ListItem(
                                  indexLabel: (index + 1).toString(),
                                  locationLabel: item.loc,
                                  buttonLabel: 'Start',
                                  journeyStatus: item.sts,
                                  subLabel: '${item.halt_dur.toString()} Mins',
                                  thirdLabel: '',
                                  journeyStatus1: djModel.journey_status1,
                                  onPressed: () {
                                    switch (djModel.journey_status1) {
                                      case 2:
                                        Fluttertoast.showToast(
                                            msg:
                                                "Please Complete the Vehicle Inspection");

                                        break;

                                      case 4:
                                        Fluttertoast.showToast(
                                            msg: "Please Start the Journey");
                                        break;

                                      case 6:
                                        if (item.sts == 1) {
                                          Fluttertoast.showToast(
                                              msg: "Journey Already Started");
                                        } else if (djList[index - 1].sts == 0) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "You cant start Until you reach the previous stop point");
                                        } else {
                                          updateStatus(item.seq, "13");
                                        }
                                        break;
                                      case 8:
                                        if (item.sts == 1) {
                                          Fluttertoast.showToast(
                                              msg: "Journey Already Started");
                                        } else if (djList[index - 1].sts == 0) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "You cant start Until you reach the previous stop point");
                                        } else {
                                          updateStatus(item.seq, "13");
                                        }
                                        break;

                                      default:
                                        break;
                                    }
                                  },
                                ),
                                const DottedLine(
                                  height: 50,
                                  color: Colors.grey,
                                ),
                              ],
                            );
                          case 3:
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ListItem(
                                  indexLabel: (index + 1).toString(),
                                  locationLabel: item.loc,
                                  buttonLabel: 'End',
                                  journeyStatus: item.sts,
                                  subLabel: duration,
                                  journeyStatus1: djModel.journey_status1,
                                  thirdLabel: '$distance $etaTime',
                                  onPressed: () {
                                    switch (djModel.journey_status1) {
                                      case 2:
                                        Fluttertoast.showToast(
                                            msg:
                                                "Please Complete the Vehicle Inspection");

                                        break;

                                      case 4:
                                        Fluttertoast.showToast(
                                            msg: "Please Start the Journey");
                                        break;

                                      case 6:
                                        if (djList[index - 1].sts == 1) {
                                          updateStatus(item.seq, '14');
                                        } else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "You can't end the Journey, Because you does'nt reached the stop point");
                                        }
                                        break;
                                      case 8:
                                        if (item.sts == 1) {
                                          Fluttertoast.showToast(
                                              msg: "Journey Already Started");
                                        } else if (djList[index - 1].sts == 0) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "You can't end the Journey, Because you does'nt reached the stop point");
                                        } else {
                                          updateStatus(item.seq, '14');
                                          Fluttertoast.showToast(
                                              msg:
                                                  "You have successfully completed Journey Thank you");
                                        }
                                        break;

                                      default:
                                        break;
                                    }
                                    // TODO: Handle end button pressed
                                    // updateStatus(item.seq, '14');
                                  },
                                ),
                              ],
                            );
                          default:
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ListItem(
                                  indexLabel: (index + 1).toString(),
                                  locationLabel: 'Vehicle\nInspection',
                                  buttonLabel: 'Upload',
                                  journeyStatus:
                                      djModel.vehInspectionStatus == null
                                          ? 0
                                          : djModel.vehInspectionStatus!,
                                  subLabel: '',
                                  thirdLabel: '',
                                  journeyStatus1: djModel.journey_status1,
                                  onPressed: () async {
                                    if (djModel.vehInspectionStatus! == 1) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Vechicle Inspection Already Done");
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ProgressHUD(
                                                      child:
                                                          DriverVehicleInspectionScreenPage(
                                                    journeyID: journeyid,
                                                  )))).then((value) {
                                        fetchDashboardData();
                                      });
                                    }
                                  },
                                ),
                                const DottedLine(
                                  height: 50,
                                  color: Colors.grey,
                                ),
                              ],
                            );
                        }
                      },
                    ),
                  )
                : const Center(
                    child: Text(
                      "No Records Found",
                      style: MyTextStyle.bigTitleTextStyle,
                    ),
                  ),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: () {
                  updateSOS();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xff09323f)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xffeb8c90)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: const BorderSide(
                          color: Color(0xffb0edff), width: 2.0),
                    ),
                  ),
                ),
                child: AppRichText(
                  text: "SOS",
                  style: TextStyle(
                      fontFamily: "RBold",
                      fontSize: 5.sp,
                      color: AppColors.colorc90),
                )),
          ]),
        ));
  }
}
