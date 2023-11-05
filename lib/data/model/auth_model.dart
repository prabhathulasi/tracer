class AuthModel {
  String? c;
  int? s;
  int? r;
  P? p;
  String? t;

  AuthModel({this.c, this.s, this.r, this.p, this.t});

  AuthModel.fromJson(Map<String, dynamic> json) {
    c = json['c'];
    s = json['s'];
    r = json['r'];
    p = json['p'] != null ? P.fromJson(json['p']) : null;
    t = json['t'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['c'] = c;
    data['s'] = s;
    data['r'] = r;
    if (p != null) {
      data['p'] = p!.toJson();
    }
    data['t'] = t;
    return data;
  }
}

class P {
  String? message;
  String? username;
  String? userid;
  String? usertype;
  String? linkName;
  int? userType;
  String? token;
  String? tZone;

  P(
      {this.message,
      this.username,
      this.userid,
      this.usertype,
      this.linkName,
      this.userType,
      this.token,
      this.tZone});

  P.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    username = json['username'];
    userid = json['userid'];
    usertype = json['usertype'];
    linkName = json['link_name'];
    userType = json['user_type'];
    token = json['token'];
    tZone = json['t_zone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['username'] = username;
    data['userid'] = userid;
    data['usertype'] = usertype;
    data['link_name'] = linkName;
    data['user_type'] = userType;
    data['token'] = token;
    data['t_zone'] = tZone;
    return data;
  }
}
