import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/data/model/driver_journey_model.dart';
import 'package:tracer/data/model/loginmodel.dart';
import 'package:tracer/screen/loginscreen.dart';

class DriverJourneyProvider extends ChangeNotifier {
  bool _isloading = false;
  bool get isLoading => _isloading;
  void setLoading(bool value) async {
    _isloading = value;
    notifyListeners();
  }

  DriverJourneyModel driverJourneyModel = DriverJourneyModel();
  Future<DriverJourneyModel> fetchDashboardData(String token) async {
    setLoading(true);
    String url = "${TracerApis.login}?controller=jm_driver";

    Map<String, dynamic> data = {};
    data.addAll({'c': "1"});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.post(url, queryParameters: data);
    setLoading(false);
    driverJourneyModel = DriverJourneyModel.fromJson(response.data);

    notifyListeners();
    return driverJourneyModel;
  }

  Future acceptRejectAction(String actionType, String token) async {
    setLoading(true);
    String url = "${TracerApis.login}?controller=jm_driver";

    Map<String, dynamic> data = {};
    data.addAll({'c': "2"});

    data.addAll({'p[journey_id]': driverJourneyModel.p!.journeyId});

    data.addAll({'p[type]': actionType});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.post(url, queryParameters: data);
    log(response.data.toString());

    var dataVal =
        (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

    if (dataVal['s'] == 0) {
      var resjson = LoginResponse.fromJson(
          HandleResponse.handleRes(response.data['p']) as Map<String, dynamic>);
      log(resjson.toString());

      if (actionType == "2") {
        fetchDashboardData(token);
        Fluttertoast.showToast(
            msg: 'Accepted Successfully',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG);
      } else {
        fetchDashboardData(token);
        Fluttertoast.showToast(
            msg: 'Rejected Successfully',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG);
      }
      notifyListeners();
    }
  }
}
