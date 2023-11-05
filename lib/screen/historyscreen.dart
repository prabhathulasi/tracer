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
import 'package:tracer/screen/journeydetailscreen.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/customsegmentedcontrol.dart';
import 'package:intl/intl.dart';
import 'package:tracer/widget/mytextstyle.dart';

class HistoryScreenPage extends StatefulWidget {
  const HistoryScreenPage({super.key});

  @override
  _HistoryScreenPageState createState() => _HistoryScreenPageState();
}

class _HistoryScreenPageState extends State<HistoryScreenPage> {
  int? groupValue = 0;
  String? token = "";
  List<Journey> _journeyList = [];
  List<Journey> _finalList = [];

  late DateTime _startDate;
  late DateTime _endDate;
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

  DateTime _getStartDateForThisWeek() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  DateTime _getEndDateForThisWeek() {
    final now = DateTime.now();
    return now.add(Duration(days: 7 - now.weekday));
  }

  void filterData(int status) {
    //List<Journey> resultData = [];
    //_finalList.clear();

    if (status == 0) {
      int todayInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      loadJourney(todayInSeconds, todayInSeconds);
    } else if (status == 1) {
      int yesterdayInSeconds = DateTime.now()
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch ~/
          1000;
      loadJourney(yesterdayInSeconds, yesterdayInSeconds);
    } else if (status == 2) {
      int thisWeekStartInSeconds = DateTime.now()
              .subtract(Duration(days: DateTime.now().weekday - 1))
              .millisecondsSinceEpoch ~/
          1000;
      int thisWeekEndInSeconds = DateTime.now()
              .add(Duration(days: 7 - DateTime.now().weekday))
              .millisecondsSinceEpoch ~/
          1000;
      loadJourney(thisWeekStartInSeconds, thisWeekEndInSeconds);
    } else if (status == 3) {
      _showDateRangePicker();
    }
    /* setState(() {
      _finalList = resultData;
    });*/
  }

  Future<void> _showDateRangePicker() async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now(),
    );
    final selectedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.brown,
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: const ColorScheme.light(primary: Color(0xff0f5164))
                .copyWith(secondary: Colors.blue),
          ),
          child: child!,
        );
      },
    );
    if (selectedDateRange != null) {
      setState(() {
        _startDate = selectedDateRange.start;
        _endDate = selectedDateRange.end;
        int startDateInSeconds = _startDate.millisecondsSinceEpoch ~/ 1000;
        int endDateInSeconds = _endDate.millisecondsSinceEpoch ~/ 1000;
        loadJourney(startDateInSeconds, endDateInSeconds);
      });
    }
  }

  epoctodatetime(int startepoc, int endepoc) {
    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(startepoc);
    DateTime endDate = DateTime.fromMillisecondsSinceEpoch(endepoc);

    String startDateString = DateFormat('MM/dd/yy hh:mm a').format(startDate);
    String endDateString = DateFormat('hh:mm a').format(endDate);

    String resultime = '$startDateString to $endDateString';

    return resultime;
  }

  Future<void> loadJourney(int startDate, int endDate) async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = TracerApis.login + "?controller=jm_manager";

    Map<String, dynamic> data = {};
    data.addAll({'c': "9"});
    data.addAll({'p[start_date_epoc]': startDate.toString()});
    data.addAll({'p[end_date_epoc]': endDate.toString()});
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
                child: const Icon(
                  Icons.account_circle,
                  color: Color(0xffb0edff),
                ),
              )),
        ],
      ),
      body: ListView(
          physics: const BouncingScrollPhysics(),
          // shrinkWrap: true,
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(10),
              child: CustomSegmentedControl(
                options: const ['Today', 'Yesterday', 'This Week', 'Custom'],
                selectedIndex: 0,
                onPress: (index) {
                  print('Selected index: $index');
                  filterData(index);
                },
              ),
            ),
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
                                          softWrap: true,
                                          style: const TextStyle(
                                              fontFamily: 'RBold',
                                              fontSize: 16,
                                              color: AppColors.color4c4),
                                        ),
                                        Gaps.hGap5,
                                        const Icon(
                                          Icons.arrow_forward_outlined,
                                          color: AppColors.color4c4,
                                        ),
                                        Gaps.hGap5,
                                        Text(_finalList[index].endLoc,
                                            softWrap: true,
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
                                              fontSize: 16,
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
                                                epoctodatetime(
                                                    _finalList[index]
                                                        .startDatetimeEpoc,
                                                    _finalList[index]
                                                        .endDatetimeEpoc),
                                                style: const TextStyle(
                                                    fontFamily: 'RRegular',
                                                    fontSize: 16,
                                                    color: AppColors.color4c4)),
                                            (_finalList[index].journeyStatus ==
                                                        2 ||
                                                    _finalList[index]
                                                            .journeyStatus ==
                                                        4)
                                                ? Text(
                                                    _finalList[index]
                                                        .journeyStatusstr,
                                                    style: const TextStyle(
                                                        fontFamily: 'RBold',
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xffabcb7b)),
                                                  )
                                                : Text(
                                                    _finalList[index]
                                                        .journeyStatusstr,
                                                    style: const TextStyle(
                                                        fontFamily: 'RBold',
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xffeb8c90)),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        convertminstohrs(
                                            _finalList[index].journeyDurMin),
                                        style: const TextStyle(
                                            fontFamily: 'RBold',
                                            fontSize: 16,
                                            color: AppColors.color4c4),
                                      ),
                                      Text(
                                        (_finalList[index].journeyDistMeters /
                                                1000)
                                            .toString(),
                                        style: const TextStyle(
                                            fontFamily: 'RRegular',
                                            fontSize: 16,
                                            color: AppColors.color4c4),
                                      )
                                    ],
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
