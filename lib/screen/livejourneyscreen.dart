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
import 'package:tracer/widget/customsegmentedcontrol.dart';
import 'package:tracer/widget/mytextstyle.dart';
import 'package:intl/intl.dart';

class LiveJourneyScreenPage extends StatefulWidget {
  const LiveJourneyScreenPage({super.key});

  @override
  _LiveJourneyScreenPageState createState() => _LiveJourneyScreenPageState();
}

class _LiveJourneyScreenPageState extends State<LiveJourneyScreenPage> {
  int? groupValue = 0;
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

    loadJourney();
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

  void filterData(int status) {
    List<Journey> resultData = [];
    _finalList.clear();

    if (status == 0) {
      resultData.addAll(_journeyList.where((_) => true));
    } else if (status == 1) {
      resultData.addAll(
          _journeyList.where((Journey) => Journey.journeyStatus == 1).toList());
    } else if (status == 2) {
      resultData.addAll(
          _journeyList.where((Journey) => Journey.journeyStatus == 2).toList());
    } else if (status == 3) {
      resultData.addAll(
          _journeyList.where((Journey) => Journey.journeyStatus == 3).toList());
    }
    setState(() {
      _finalList = resultData;
    });
  }

  Future<void> loadJourney() async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = TracerApis.login + "?controller=jm_manager";

    Map<String, dynamic> data = {};
    data.addAll({'c': "6"});
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
    progress?.dismiss();
    setState(() {
      _finalList.addAll(_journeyList);
    });
  }

  epoctoenddatetime(int endepoc) {
    DateTime endDate = DateTime.fromMillisecondsSinceEpoch(endepoc);

    String endDateString = DateFormat('hh:mm a').format(endDate);

    String resultime = endDateString;

    return resultime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: CustomSegmentedControl(
                options: const ['All', 'Pending', 'Ongoing', 'Rejected'],
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          statusIcon(
                                              _finalList[index].journeyStatus),
                                          Gaps.hGap5,
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: SizedBox(
                                              width: 80, // fixed text width
                                              child: Text(
                                                _finalList[index].startLoc,
                                                softWrap: true,
                                                style: const TextStyle(
                                                    fontFamily: 'RBold',
                                                    fontSize: 16,
                                                    color: Color(0xffb8c3c4)),
                                              ),
                                            ),
                                          ),
                                          Gaps.hGap5,
                                          const Icon(
                                              Icons.arrow_forward_outlined,
                                              color: Color(0xffb8c3c4)),
                                          Gaps.hGap5,
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: SizedBox(
                                              width: 80, // fixed text width
                                              child: Text(
                                                  _finalList[index].endLoc,
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                      fontFamily: 'RBold',
                                                      fontSize: 16,
                                                      color:
                                                          Color(0xffb8c3c4))),
                                            ),
                                          ),
                                          Container(
                                            child: LinearPercentIndicator(
                                              width: 80.0,
                                              lineHeight: 12.0,
                                              percent: _finalList[index]
                                                      .complPercent /
                                                  100,
                                              trailing: Text(
                                                  '${_finalList[index].complPercent.toString()}%',
                                                  style: const TextStyle(
                                                      fontFamily: 'RRegular',
                                                      fontSize: 12,
                                                      color:
                                                          Color(0xffb8c3c4))),
                                              barRadius:
                                                  const Radius.circular(4),
                                              backgroundColor: Colors.grey,
                                              progressColor: Colors.greenAccent,
                                            ),
                                          ),
                                          const Spacer(),
                                          (_finalList[index].sos == 7)
                                              ? Container(
                                                  width: 40,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xffd69093),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      'SOS',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff09323f),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 40,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xff197894),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      'SOS',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff09323f),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 8,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          (_finalList[index].sos == 7)
                                              ? Icon(
                                                  LucideIcons.bell,
                                                  size: 25,
                                                  color: Theme.of(context)
                                                      .errorColor,
                                                )
                                              : Icon(
                                                  LucideIcons.bell,
                                                  size: 25,
                                                  color: Color(0xff197894),
                                                )
                                        ],
                                      ),
                                    ],
                                  )),
                                  /*Row(
                                    children: [
                                      (_finalList[index].sos == 7)
                                          ? Container(
                                              width: 40,
                                              height: 20,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xffd69093),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'SOS',
                                                  style: TextStyle(
                                                    color: Color(0xff09323f),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 40,
                                              height: 20,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xff197894),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'SOS',
                                                  style: TextStyle(
                                                    color: Color(0xff09323f),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      (_finalList[index].sos == 7)
                                          ? Icon(
                                              LucideIcons.bell,
                                              size: 25,
                                              color:
                                                  Theme.of(context).errorColor,
                                            )
                                          : Icon(
                                              LucideIcons.bell,
                                              size: 25,
                                              color: Color(0xff197894),
                                            )
                                    ],
                                  )*/
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
                                              color: Color(0xffb8c3c4)),
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
                                              color: Color(0xffb8c3c4)),
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
                                            Text(_finalList[index].loc,
                                                style: const TextStyle(
                                                    fontFamily: 'RRegular',
                                                    fontSize: 15,
                                                    color: Color(0xffb8c3c4))),
                                            Text(
                                              epochToTimeAgo(_finalList[index]
                                                  .lastUpdateEpoc),
                                              style: const TextStyle(
                                                  fontFamily: 'RRegular',
                                                  fontSize: 12,
                                                  color: Color(0xffb8c3c4)),
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
                                            fontSize: 15,
                                            color: Color(0xffb8c3c4)),
                                      ),
                                      Text(
                                        '${(_finalList[index].journeyDistMeters / 1000).toString()} km - ${epoctoenddatetime(_finalList[index].journeyEtaEpoc)}',
                                        style: const TextStyle(
                                            fontFamily: 'RRegular',
                                            fontSize: 12,
                                            color: Color(0xffb8c3c4)),
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
