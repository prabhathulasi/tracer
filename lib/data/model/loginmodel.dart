// TODO need to remove at production
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CommonResponse {
  @JsonKey(required: false)
  String c;

  @JsonKey(required: false)
  double s;

  @JsonKey(required: false)
  double r;

  @JsonKey(required: false)
  dynamic t;

  @JsonKey(required: false)
  dynamic p;

  CommonResponse({
    required this.c,
    required this.r,
    required this.s,
    this.t,
    this.p,
  });

  factory CommonResponse.fromJson(Map<String, dynamic> json) => CommonResponse(
        c: json["c"] as String,
        r: json["r"],
        s: json["s"],
        t: json["t"],
        p: json["p"],
      );

  Map<String, dynamic> toJson() => {
        "c": c,
        "r": r,
        "s": s,
        "t": t,
        "p": p,
      };
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(required: false)
  String? message;

  @JsonKey(required: false)
  String? username;

  @JsonKey(required: false)
  String? userid;

  @JsonKey(required: false)
  String? usertype;

  @JsonKey(required: false)
  String? link_name;

  @JsonKey(required: false)
  String? token;

  @JsonKey(required: false)
  String? t_zone;

  LoginResponse({
    this.username,
    this.link_name,
    this.message,
    this.t_zone,
    this.token,
    this.userid,
    this.usertype,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        username: json["username"],
        link_name: json["link_name"],
        message: json["message"],
        t_zone: json["t_zone"],
        token: json["token"],
        userid: json["userid"],
        usertype: json["usertype"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "link_name": link_name,
        "message": message,
        "t_zone": t_zone,
        "token": token,
        "userid": userid,
        "usertype": usertype,
      };
}
