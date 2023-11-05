import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/common/connectivity.dart';
import 'package:tracer/common/gaps.dart';

import 'package:tracer/data/model/journeymodel.dart';
import 'package:intl/intl.dart';
import 'package:tracer/screen/journeydetailscreen.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/mytextstyle.dart';

class NotificationScreenPage extends StatefulWidget {
  const NotificationScreenPage({super.key});

  @override
  _NotificationScreenPageState createState() => _NotificationScreenPageState();
}

class _NotificationScreenPageState extends State<NotificationScreenPage> {
  String? token = "";
  List<Journey> _journeyList = [];
  List<Journey> _finalList = [];
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

    loadJourney(1663842600, 1669875193);
  }

  logoutClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("status", "0");
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

  String epochToTimeAgo(int epoch) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - epoch;
    final seconds = diff ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (seconds < 60) {
      return 'Just now';
    } else if (minutes < 60) {
      return '$minutes minutes ago';
    } else if (hours < 24) {
      return '$hours hours ago';
    } else {
      return '$days days ago';
    }
  }

  epoctodatetime(String epoc) {
    DateTime eventDate = DateTime.fromMillisecondsSinceEpoch(int.parse(epoc));

    String eventDateString = DateFormat('dd/MM/yy hh:mm a').format(eventDate);

    String resultime = '$eventDateString';

    return resultime;
  }

  Future<void> loadJourney(int startDate, int endDate) async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = TracerApis.login + "?controller=jm_manager";

    Map<String, dynamic> data = {};
    data.addAll({'c': "10"});

    data.addAll({'t': "0"});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    Response response = await dio.post(url, queryParameters: data);
    print(response.data.toString());

    try {
      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

      _journeyList = (jsonMap['p'] as List<dynamic>)
          .map((e) => Journey.fromJson(e))
          .toList();

      print(_journeyList);
    } catch (e) {
      print(e.toString());
      setState(() {
        _journeyList.clear();
        _finalList.clear();
      });
    }
    setState(() {
      _finalList.clear();
      _finalList.addAll(_journeyList);
      _journeyList.clear();
    });
    progress?.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff09313c),
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
                      title: Text("CONFIRMATION"),
                      content: Text("ARE YOU SURE TO LOGOUT?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            logoutClear();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          },
                          child: Text('YES'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context, 'OK');
                          },
                          child: Text('NO'),
                        ),
                      ],
                    ),
                  );
                },
                child:
                    const Icon(Icons.account_circle, color: Color(0xffb0edff)),
              )),
        ],
      ),
      body: ListView(
          physics: const BouncingScrollPhysics(),
          // shrinkWrap: true,
          children: [
            const SizedBox(
              height: 5,
            ),
            (_finalList.isNotEmpty)
                ? ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _finalList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => JourneyDetails(
                                        journeyValue: _finalList[index],
                                      )));
                        },
                        child: Container(
                          color: Color(0xFF0f5164),
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        statusIcon(
                                            _finalList[index].journeyStatus),
                                        Gaps.hGap5,
                                        Text(
                                          _finalList[index].startLoc,
                                          style: const TextStyle(
                                              fontFamily: 'RBold',
                                              fontSize: 16,
                                              color: AppColors.color4c4),
                                        ),
                                        Gaps.hGap5,
                                        const Icon(Icons.arrow_forward_outlined,
                                            color: AppColors.color4c4),
                                        Gaps.hGap5,
                                        Text(_finalList[index].endLoc,
                                            style: const TextStyle(
                                                fontFamily: 'RBold',
                                                fontSize: 16,
                                                color: AppColors.color4c4)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Gaps.vGap4,
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          LucideIcons.truck,
                                          color: Color(0xffb8c3c4),
                                          size: 18,
                                        ),
                                        Gaps.hGap5,
                                        Text(
                                          _finalList[index].vehName,
                                          style: const TextStyle(
                                              fontFamily: 'RRegular',
                                              fontSize: 16,
                                              color: AppColors.color4c4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          LucideIcons.user,
                                          color: Color(0xffb8c3c4),
                                          size: 18,
                                        ),
                                        Gaps.hGap5,
                                        Text(
                                          _finalList[index].drvName,
                                          style: const TextStyle(
                                              fontFamily: 'RRegular',
                                              fontSize: 15,
                                              color: AppColors.color4c4),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Gaps.vGap4,
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          LucideIcons.clock,
                                          color: Color(0xffb8c3c4),
                                          size: 18,
                                        ),
                                        Gaps.hGap5,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                _finalList[index]
                                                    .journeyEventStr,
                                                style: const TextStyle(
                                                    fontFamily: 'RRegular',
                                                    fontSize: 16,
                                                    color: AppColors.color4c4)),
                                            Text(
                                              epoctodatetime(_finalList[index]
                                                  .eventDatetimeEpoc),
                                              style: const TextStyle(
                                                  fontFamily: 'RRegular',
                                                  fontSize: 12,
                                                  color: AppColors.color4c4),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1,
                        color: Theme.of(context).primaryColor,
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      "No Records Found",
                      style: MyTextStyle.bigTitleTextStyle,
                    ),
                  ),
          ]),
    );
  }

  Widget buildSegment(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 22, color: Colors.black),
    );
  }

  Widget statusIcon(int jstatus) {
    switch (jstatus) {
      case 1:
        return const Icon(
          Icons.pending_actions,
          color: Color(0xffd69093),
          size: 18,
        );
        break;
      case 2:
        return const Icon(FontAwesomeIcons.solidCircleCheck,
            color: Colors.green, size: 18);
        break;
      case 3:
        return const Icon(FontAwesomeIcons.solidCircleXmark,
            color: Color(0xffd69093), size: 18);
        break;
      case 4:
        return const Icon(Icons.route_rounded, color: Colors.green, size: 18);
        break;
      case 5:
        return const Icon(Icons.expand_circle_down,
            color: Colors.grey, size: 18);
        break;
      default:
        return const Icon(FontAwesomeIcons.solidCircleCheck,
            color: Colors.green, size: 18);
    }
  }
}
