import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget customAppBar(String? title) {
  return AppBar(
    backgroundColor: const Color(0xFF225f70),
    automaticallyImplyLeading: false,
    title: const Text("TRACER JM",
        style: TextStyle(
            fontFamily: 'Bold', fontSize: 35, color: Color(0xffb0edff))),
    actions: <Widget>[
      Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.search,
              size: 26.0,
            ),
          )),
      Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {},
            child: const Icon(Icons.more_vert),
          )),
      Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {},
            child: const Icon(Icons.more_vert),
          )),
    ],
  );
}
