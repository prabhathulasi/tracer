class DriverJourneyModel {
  final String c;
  final int s;
  final int r;
  final Payload p;
  final dynamic t;

  DriverJourneyModel(
      {this.c = "", this.s = 0, this.r = 0, required this.p, this.t});

  factory DriverJourneyModel.fromJson(Map<String, dynamic> json) {
    return DriverJourneyModel(
      c: json['c'] ?? "",
      s: json['s'] ?? 0,
      r: json['r'] ?? 0,
      p: Payload.fromJson(json['p']),
      t: json['t'],
    );
  }
}

class Payload {
  final String message;
  final int journeyId;
  final int vehId;
  final String vehName;
  final int drvId;
  final String drvName;
  final String vehType;
  final int capacity;
  final int startTimeEpoc;
  final String startTimeStr;
  final String startLoc;
  final String endLoc;
  final int journeyDurMin;
  final int journeyDistMeters;
  final int journeyEtaEpoc;
  final String journeyEtaStr;
  final int journey_status;
  final int journey_status1;
  final int? vehInspectionStatus;
  List<DriverJourney> pointsArr;

  Payload({
    this.message = "",
    this.journeyId = 0,
    this.vehId = 0,
    this.vehName = "",
    this.drvId = 0,
    this.drvName = "",
    this.vehType = "",
    this.capacity = 0,
    this.startTimeEpoc = 0,
    this.startTimeStr = "",
    this.startLoc = "",
    this.endLoc = "",
    this.journeyDurMin = 0,
    this.journeyDistMeters = 0,
    this.journeyEtaEpoc = 0,
    this.journeyEtaStr = "",
    this.journey_status = 0,
    this.journey_status1 = 0,
    this.vehInspectionStatus,
    this.pointsArr = const [],
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    List<DriverJourney> pointsArr = [];
    if (json.containsKey('points_arr')) {
      var list = json['points_arr'] as List;
      pointsArr = list.map((i) => DriverJourney.fromJson(i)).toList();
    }
    return Payload(
      message: json['message'] ?? "",
      journeyId: json['journey_id'] ?? 0,
      vehId: json['veh_id'] ?? 0,
      vehName: json['veh_name'] ?? "",
      drvId: json['drv_id'] ?? 0,
      drvName: json['drv_name'] ?? "",
      vehType: json['veh_type'] ?? "",
      capacity: json['capacity'] ?? 0,
      startTimeEpoc: json['start_time_epoc'] ?? 0,
      startTimeStr: json['start_time_str'] ?? "",
      startLoc: json['start_loc'] ?? "",
      endLoc: json['end_loc'] ?? "",
      journeyDurMin: json['journey_dur_min'] ?? 0,
      journeyDistMeters: json['journey_dist_meters'] ?? 0,
      journeyEtaEpoc: json['journey_eta_epoc'] ?? 0,
      journeyEtaStr: json['journey_eta_str'] ?? "",
      journey_status: json['journey_status'] ?? 0,
      journey_status1: json['journey_status1'] ?? 0,
      vehInspectionStatus: json["veh_insp_sts"],
      pointsArr: pointsArr,
    );
  }
}

class DriverJourney {
  int seq;
  int type;
  String lat;
  String lon;
  String loc;
  int halt_dur;
  int dist;
  String eta;
  int dur;
  int sts;

  DriverJourney(
      {this.seq = 0,
      this.type = 0,
      this.lat = '',
      this.lon = '',
      this.loc = '',
      this.halt_dur = 0,
      this.dist = 0,
      this.eta = '',
      this.dur = 0,
      this.sts = 0});

  factory DriverJourney.fromJson(Map<String, dynamic> json) {
    return DriverJourney(
        seq: json['seq'] ?? 0,
        type: json['type'] ?? 0,
        lat: json['lat'] ?? '',
        lon: json['lon'] ?? '',
        loc: json['loc'] ?? '',
        halt_dur: json['halt_dur'] ?? 0,
        dist: json['dist'] ?? 0,
        eta: json['eta'] ?? '',
        dur: json['dur'] ?? 0,
        sts: json['sts'] ?? 0);
  }
}
