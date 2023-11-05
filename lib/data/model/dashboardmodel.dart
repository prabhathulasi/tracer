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

class DashboardModel {
  final String? sno;
  final int? value;
  final String? label;

  DashboardModel({this.sno, this.value, this.label});

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      sno: json['sno'],
      value: json['value'],
      label: json['label'],
    );
  }
}
