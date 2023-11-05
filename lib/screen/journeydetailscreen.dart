import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/common/connectivity.dart';
import 'package:tracer/common/gaps.dart';
import 'package:tracer/data/model/journeydetailmodel.dart';
import 'package:tracer/data/model/journeymodel.dart';
import 'package:tracer/screen/imagepreviewlistscreen.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/themes/app_colors.dart';

class JourneyDetails extends StatefulWidget {
  final Journey journeyValue;
  const JourneyDetails({key, required this.journeyValue}) : super(key: key);

  @override
  State<JourneyDetails> createState() => _JourneyDetailsState();
}

class _JourneyDetailsState extends State<JourneyDetails> {
  String? token;
  List<Event> _eventDetails = [];
  List<Violation> _violationDetails = [];
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
    loadJourneyDetails();
  }

  logoutClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("status", "0");
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

  Future<void> loadJourneyDetails() async {
    String url = TracerApis.login + "?controller=jm_manager";

    Map<String, dynamic> data = {};
    data.addAll({'c': "7"});
    data.addAll({'p[journey_id]': widget.journeyValue.journeyId});
    data.addAll({'t': "0"});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    Response response = await dio.post(url, queryParameters: data);
    print(response.data.toString());
    List<Event> _eventresult = [];
    List<Violation> _violationresult = [];
    try {
      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

      Map<String, dynamic> subMap =
          jsonMap['p']['journey_details'] as Map<String, dynamic>;
      _eventresult = (subMap['events'] as List<dynamic>)
          .map((e) => Event.fromJson(e))
          .toList();
      _violationresult = (subMap['violations'] as List<dynamic>)
          .map((e) => Violation.fromJson(e))
          .toList();

      //print(_eventresult);
    } catch (e) {
      print(e.toString());
      setState(() {
        _eventresult.clear();
        _violationresult.clear();
      });
    }
    setState(() {
      _eventDetails.addAll(_eventresult);
      _violationDetails.addAll(_violationresult);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff09313c),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xffb0edff)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xff052028),
        automaticallyImplyLeading: false,
        title: const Text("Live Journey",
            style: TextStyle(
                fontFamily: 'RRegular',
                fontSize: 24,
                color: Color(0xffb0edff))),
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
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 90,
                      child: Center(
                        child: statusIcon(widget.journeyValue.journeyStatus),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 90,
                                child: Text(
                                  widget.journeyValue.startLoc,
                                  style: const TextStyle(
                                      fontFamily: 'RBold',
                                      fontSize: 16,
                                      color: AppColors.color4c4),
                                ),
                              ),
                              Gaps.hGap5,
                              const Icon(
                                Icons.arrow_forward_outlined,
                                color: Color(0xffb8c3c4),
                              ),
                              Gaps.hGap5,
                              SizedBox(
                                width: 90,
                                child: Text(
                                  widget.journeyValue.endLoc,
                                  style: const TextStyle(
                                      fontFamily: 'RBold',
                                      fontSize: 16,
                                      color: AppColors.color4c4),
                                ),
                              )
                            ],
                          ),
                          Gaps.vGap10,
                          Center(
                            child: SizedBox(
                              width: 200,
                              child: LinearPercentIndicator(
                                width: 160.0,
                                lineHeight: 20.0,
                                percent: widget.journeyValue.complPercent / 100,
                                trailing: Text(
                                    widget.journeyValue.complPercent.toString(),
                                    style: const TextStyle(
                                        fontFamily: 'Regular',
                                        fontSize: 15,
                                        color: Color(0xffb8c3c4))),
                                barRadius: const Radius.circular(4),
                                backgroundColor: Colors.grey,
                                progressColor: Colors.greenAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gaps.hGap5,
                    Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImagePreviewList(
                                          journeyid: widget
                                              .journeyValue.journeyId
                                              .toString(),
                                        )));
                          },
                          child: const Icon(Icons.photo_album,
                              size: 50, color: Color(0xffb0edff)),
                        ))
                  ],
                ),
              ),
              Gaps.vGap20,
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.truck,
                            color: Color(0xffb8c3c4),
                            size: 30,
                          ),
                          Gaps.hGap5,
                          Text(
                            widget.journeyValue.vehName,
                            style: const TextStyle(
                                fontFamily: 'RRegular',
                                fontSize: 24,
                                color: AppColors.color4c4),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.user,
                            color: Color(0xffb8c3c4),
                            size: 25,
                          ),
                          Gaps.hGap5,
                          Text(
                            widget.journeyValue.drvName,
                            style: const TextStyle(
                                fontFamily: 'RRegular',
                                fontSize: 24,
                                color: AppColors.color4c4),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Gaps.vGap20,
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            color: Color(0xffb8c3c4),
                            size: 25,
                          ),
                          Gaps.hGap5,
                          Text(
                            widget.journeyValue.loc,
                            style: const TextStyle(
                                fontFamily: 'RRegular',
                                fontSize: 24,
                                color: AppColors.color4c4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gaps.vGap20,
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    (widget.journeyValue.sos == 7)
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
                    Text(
                      epochToTimeAgo(widget.journeyValue.lastUpdateEpoc),
                      style: const TextStyle(
                          fontFamily: 'RRegular',
                          fontSize: 16,
                          color: AppColors.color4c4),
                    ),
                    Gaps.hGap10,
                  ],
                ),
              ),
              //Gaps.vGap20,

              Gaps.vGap20,
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      color: Color(0xFF0f5164),
                      child: ListView.builder(
                        itemCount: _eventDetails.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.note_alt_sharp,
                                size: 25, color: Color(0xffb8c3c4)),
                            title: Text(_eventDetails[index].eventStr,
                                style: const TextStyle(
                                    fontFamily: 'RRegular',
                                    fontSize: 15,
                                    color: AppColors.color4c4)),
                            subtitle: Text(
                                epochToTimeAgo(
                                    _eventDetails[index].datetimeEpoc),
                                style: const TextStyle(
                                    fontFamily: 'RRegular',
                                    fontSize: 12,
                                    color: AppColors.color4c4)),
                          );
                        },
                      ),
                    ),
                    Gaps.vGap20,
                    Container(
                      height: 200,
                      color: Color(0xFF0f5164),
                      child: ListView.builder(
                        itemCount: _violationDetails.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(FontAwesomeIcons.bell,
                                size: 25, color: Color(0xffb8c3c4)),
                            title: Text(_violationDetails[index].eventStr,
                                style: const TextStyle(
                                    fontFamily: 'RRegular',
                                    fontSize: 15,
                                    color: AppColors.color4c4)),
                            subtitle: Text(
                                epochToTimeAgo(
                                    _violationDetails[index].datetimeEpoc),
                                style: const TextStyle(
                                    fontFamily: 'RRegular',
                                    fontSize: 12,
                                    color: AppColors.color4c4)),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Gaps.vGap20,
            ],
          )
        ],
      ),
    );
  }
}

Widget statusIcon(int jstatus) {
  switch (jstatus) {
    case 1:
      return const Icon(
        Icons.pending_actions,
        color: Color(0xffd69093),
        size: 50,
      );
      break;
    case 2:
      return const Icon(FontAwesomeIcons.solidCircleCheck,
          color: Colors.green, size: 50);
      break;
    case 3:
      return const Icon(FontAwesomeIcons.solidCircleXmark,
          color: Color(0xffd69093), size: 50);
      break;
    case 4:
      return const Icon(Icons.route_rounded, color: Colors.green, size: 50);
      break;
    case 5:
      return const Icon(Icons.expand_circle_down, color: Colors.grey, size: 50);
      break;
    default:
      return const Icon(FontAwesomeIcons.solidCircleCheck,
          color: Colors.green, size: 50);
  }
}
