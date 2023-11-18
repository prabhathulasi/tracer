import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/common/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:tracer/data/model/imagepreviewmodel.dart';
import 'package:tracer/screen/fullscreenpreview.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/themes/app_colors.dart';

class ImagePreviewList extends StatefulWidget {
  //const ImagePreviewList({super.key});
  final String journeyid;
  const ImagePreviewList({key, required this.journeyid}) : super(key: key);

  @override
  State<ImagePreviewList> createState() => _ImagePreviewListState();
}

class _ImagePreviewListState extends State<ImagePreviewList> {
  String? token;
  List<ImagePreviewModel> _imagelist = [];
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
    fetchImageData();
  }

  void fetchImageData() async {
    String url = TracerApis.login + "?controller=jm_manager";

    Map<String, dynamic> data = {};
    data.addAll({'c': "8"});
    //data.addAll({'p[journey_id]': widget.journeyid.toString()});
    data.addAll({'p[journey_id]': "155"});

    data.addAll({'t': "0"});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    Response response = await dio.post(url, queryParameters: data);
    print(response.data.toString());
    List<ImagePreviewModel> jsonList = [];

    Map<String, dynamic> jsonMap =
        (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

    if (jsonMap['s'] == 0) {
      jsonList = (jsonMap['p'] as List<dynamic>)
          .map((e) => ImagePreviewModel.fromJson(e))
          .toList();
      setState(() {
        _imagelist.addAll(jsonList);
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
  }

  logoutClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("status", "0");
  }

  Future<Widget> _loadImage(String imageUrl) async {
    try {
      var image = await Image.network(imageUrl);
      return image;
    } catch (exception) {
      if (exception is HttpException) {
        return const Icon(Icons.no_photography_outlined);
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff09313c),
      appBar: AppBar(
        backgroundColor: const Color(0xff052028),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xffb0edff)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text("Journey Details",
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
                      content: Text("Are You Sure To Logout?"),
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
      body: ListView.builder(
        itemCount: _imagelist.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Color(0xFF0f5164),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 200.0,
                        height: 200.0,
                        child: FadeInImage.assetNetwork(
                            placeholder: "assets/noimage.jpeg",
                            image: _imagelist[index].path),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.fullscreen,
                          size: 25,
                          color: Color(0xffb8c3c4),
                        ),
                        onPressed: () {
                          // Perform action for the fullscreen icon
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FullScreenPreview(image: _imagelist[index]),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DateFormat('dd-MM-yyyy h:mm a')
                        .format(DateTime.fromMillisecondsSinceEpoch(
                          _imagelist[index].datetimeEpoc,
                        ))
                        .toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.color4c4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      /*ListView.builder(
        itemCount: _imagelist.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          ImagePreviewModel image = _imagelist[index];
          return ListTile(
            leading: SizedBox(
              width: 200.0,
              height: 200.0,
              child: _getLeadingIcon(image),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenPreview(image: image),
                  ),
                );
              },
            ),
          );
        },
      ),*/
    );
  }
}

Widget _getLeadingIcon(ImagePreviewModel image) {
  if (image.path.endsWith('.pdf')) {
    return const Icon(Icons.picture_as_pdf,
        size: 100, color: Color(0xffb0edff));
  }
  return FadeInImage.assetNetwork(
      placeholder: 'assets/noimage.jpeg', image: image.path);
}
