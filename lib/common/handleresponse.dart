import 'dart:convert';

class HandleResponse {
  static handleRes(response) {
    Map<String, dynamic>? resJson;
    if (response is String) {
      return resJson = json.decode(response);
    } else if (response is Map<String, dynamic>) {
      return resJson = response;
    } else {
      print("Invaild Query");
      // throw DioError(message: 'Data parsing error');
    }
  }
}
