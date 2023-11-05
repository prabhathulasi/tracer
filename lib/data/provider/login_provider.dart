import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/data/model/auth_model.dart';

class LoginProvider extends ChangeNotifier {
  bool _isloading = false;
  bool get isLoading => _isloading;

  AuthModel authModel = AuthModel();
  void setLoading(bool value) async {
    _isloading = value;
    notifyListeners();
  }

  Map _deviceData = {};
  Map get deviceData => _deviceData;
  void setDeviceData(Map data) async {
    _deviceData = data;
    notifyListeners();
  }

  Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
    notifyListeners();
    return <String, dynamic>{
      'systemName': build.manufacturer,
      'model': build.model,
      'id': build.id,
      'systemVersion': build.version.release,
    };
  }

  String? fcmToken;

  Future getFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    notifyListeners();
  }

  Future<AuthModel> loginAPI(String email, String password) async {
    await getFCMToken();
    setLoading(true);

    String url = "${TracerApis.login}?uts=45944381&controller=login";
    //print(url);

    Map<String, dynamic> pData = {};
    pData.addAll({'username': email});
    pData.addAll({'password': password});
    pData.addAll({'app_type': 1});
    pData.addAll({'mob_name': deviceData['systemName']});
    pData.addAll({'mob_model': deviceData['model']});
    pData.addAll({'mob_uuid': deviceData['id']});
    pData.addAll({'mob_sw_ver': deviceData['systemVersion']});
    pData.addAll({'app_sw_ver': "1.0"});
    pData.addAll({'device_id': fcmToken});

    Map<String, dynamic> data = {};
    data.addAll({'c': "1"});

    data.addAll({'p': pData});
    data.addAll({"t": 0});
    log(data.toString());
    var dio = Dio();
    var response = await dio.post(url, queryParameters: data);
    setLoading(false);
    authModel = AuthModel.fromJson(response.data);

    notifyListeners();
    return authModel;
  }
}
