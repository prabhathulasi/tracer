import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/connectivity.dart';
import 'package:tracer/data/model/imagepreviewmodel.dart';
import 'package:tracer/screen/loginscreen.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String? image;
  final bool? webImage;

  ImagePreviewScreen({required this.image, this.webImage});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreviewScreen> {
  bool isInternet = true;
  @override
  void initState() {
    super.initState();
    connectioncheck();
  }

  connectioncheck() async {
    if (await ConnectivityCheck().isInternetAvailable()) {
      isInternet = true;
    } else {
      isInternet = false;
    }
  }

  logoutClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("status", "0");
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
      body: Center(
        child: widget.webImage! == false
            ? Image.file(
                File(
                  widget.image!,
                ),
                height: MediaQuery.of(context).size.height / 2,
              )
            : Image.network(widget.image!),
      ),
    );
  }
}
