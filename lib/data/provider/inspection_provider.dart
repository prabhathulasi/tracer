import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/common/handleresponse.dart';

class InspectionProvider extends ChangeNotifier {
  completeVehicleInspection(int journeyId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    String url = "${TracerApis.vecInpDone}?controller=jm_driver";
    Map<String, dynamic> data = {};
    Map<String, dynamic> pData = {};
    pData.addAll({'journey_id': journeyId});
    pData.addAll({'type': 2});
    data.addAll({'c': "8"});
    data.addAll({'p': pData});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.post(url, queryParameters: data);
    var dataVal =
        (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

    return dataVal["p"];
  }
}
