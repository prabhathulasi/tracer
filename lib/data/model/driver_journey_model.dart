class DriverJourneyModel {
  String? c;
  int? s;
  int? r;
  P? p;
  String? t;

  DriverJourneyModel({this.c, this.s, this.r, this.p, this.t});

  DriverJourneyModel.fromJson(Map<String, dynamic> json) {
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
  int? journeyId;
  int? vehId;
  String? vehName;
  int? drvId;
  String? drvName;
  String? vehType;
  int? capacity;
  int? startTimeEpoc;
  String? startTimeStr;
  String? startLoc;
  String? endLoc;
  int? journeyDurMin;
  int? journeyDistMeters;
  int? journeyEtaEpoc;
  String? journeyEtaStr;
  int? journeyStatus;
  int? journeyStatus1;
  int? vehInspSts;
  List<PointsArr>? pointsArr;

  P(
      {this.message,
      this.journeyId,
      this.vehId,
      this.vehName,
      this.drvId,
      this.drvName,
      this.vehType,
      this.capacity,
      this.startTimeEpoc,
      this.startTimeStr,
      this.startLoc,
      this.endLoc,
      this.journeyDurMin,
      this.journeyDistMeters,
      this.journeyEtaEpoc,
      this.journeyEtaStr,
      this.journeyStatus,
      this.journeyStatus1,
      this.vehInspSts,
      this.pointsArr});

  P.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    journeyId = json['journey_id'];
    vehId = json['veh_id'];
    vehName = json['veh_name'];
    drvId = json['drv_id'];
    drvName = json['drv_name'];
    vehType = json['veh_type'];
    capacity = json['capacity'];
    startTimeEpoc = json['start_time_epoc'];
    startTimeStr = json['start_time_str'];
    startLoc = json['start_loc'];
    endLoc = json['end_loc'];
    journeyDurMin = json['journey_dur_min'];
    journeyDistMeters = json['journey_dist_meters'];
    journeyEtaEpoc = json['journey_eta_epoc'];
    journeyEtaStr = json['journey_eta_str'];
    journeyStatus = json['journey_status'];
    journeyStatus1 = json['journey_status1'];
    vehInspSts = json['veh_insp_sts'];
    if (json['points_arr'] != null) {
      pointsArr = <PointsArr>[];
      json['points_arr'].forEach((v) {
        pointsArr!.add(PointsArr.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['journey_id'] = journeyId;
    data['veh_id'] = vehId;
    data['veh_name'] = vehName;
    data['drv_id'] = drvId;
    data['drv_name'] = drvName;
    data['veh_type'] = vehType;
    data['capacity'] = capacity;
    data['start_time_epoc'] = startTimeEpoc;
    data['start_time_str'] = startTimeStr;
    data['start_loc'] = startLoc;
    data['end_loc'] = endLoc;
    data['journey_dur_min'] = journeyDurMin;
    data['journey_dist_meters'] = journeyDistMeters;
    data['journey_eta_epoc'] = journeyEtaEpoc;
    data['journey_eta_str'] = journeyEtaStr;
    data['journey_status'] = journeyStatus;
    data['journey_status1'] = journeyStatus1;
    data['veh_insp_sts'] = vehInspSts;
    if (pointsArr != null) {
      data['points_arr'] = pointsArr!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PointsArr {
  int? seq;
  int? type;
  String? lat;
  String? lon;
  String? loc;
  int? haltDur;
  int? dist;
  String? eta;
  int? dur;
  int? sts;

  PointsArr(
      {this.seq,
      this.type,
      this.lat,
      this.lon,
      this.loc,
      this.haltDur,
      this.dist,
      this.eta,
      this.dur,
      this.sts});

  PointsArr.fromJson(Map<String, dynamic> json) {
    seq = json['seq'];
    type = json['type'];
    lat = json['lat'];
    lon = json['lon'];
    loc = json['loc'];
    haltDur = json['halt_dur'];
    dist = json['dist'];
    eta = json['eta'];
    dur = json['dur'];
    sts = json['sts'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seq'] = seq;
    data['type'] = type;
    data['lat'] = lat;
    data['lon'] = lon;
    data['loc'] = loc;
    data['halt_dur'] = haltDur;
    data['dist'] = dist;
    data['eta'] = eta;
    data['dur'] = dur;
    data['sts'] = sts;
    return data;
  }
}
