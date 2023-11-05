class Journey {
  int journeyId;
  int journeyStatus;
  String journeyStatusstr;
  String startLoc;
  String endLoc;
  int vehId;
  String vehName;
  int drvId;
  String drvName;
  String loc;
  int lastUpdateEpoc;
  int complPercent;
  int sos;
  int sosEpoch;
  int alarm;
  int journeyDurMin;
  int journeyDistMeters;
  int journeyEtaEpoc;
  int passengerCount;
  int vtsStatus;
  List<JourneyPoint> pointsArr;
  int startDatetimeEpoc;
  int endDatetimeEpoc;
  String journeyEventStr;
  String eventDatetimeEpoc;

  Journey(
      {this.journeyId = 0,
      this.journeyStatus = 0,
      this.journeyStatusstr = '',
      this.startLoc = '',
      this.endLoc = '',
      this.vehId = 0,
      this.vehName = '',
      this.drvId = 0,
      this.drvName = '',
      this.loc = '',
      this.lastUpdateEpoc = 0,
      this.complPercent = 0,
      this.sos = 0,
      this.sosEpoch = 0,
      this.alarm = 0,
      this.journeyDurMin = 0,
      this.journeyDistMeters = 0,
      this.journeyEtaEpoc = 0,
      this.passengerCount = 0,
      this.vtsStatus = 0,
      this.pointsArr = const [],
      this.startDatetimeEpoc = 0,
      this.endDatetimeEpoc = 0,
      this.journeyEventStr = '',
      this.eventDatetimeEpoc = '0'});

  factory Journey.fromJson(Map<String, dynamic> json) {
    List<JourneyPoint> pointsArr = [];
    if (json.containsKey('points_arr')) {
      var list = json['points_arr'] as List;
      pointsArr = list.map((i) => JourneyPoint.fromJson(i)).toList();
    }
    return Journey(
      journeyId: json['journey_id'] ?? 0,
      journeyStatus: json['journey_status'] ?? 0,
      journeyStatusstr: json['journey_status_str'] ?? '',
      startLoc: json['start_loc'] ?? '',
      endLoc: json['end_loc'] ?? '',
      vehId: json['veh_id'] ?? 0,
      vehName: json['veh_name'] ?? '',
      drvId: json['drv_id'] ?? 0,
      drvName: json['drv_name'] ?? '',
      loc: json['loc'] ?? '',
      lastUpdateEpoc: json['last_update_epoc'] ?? 0,
      complPercent: json['compl_percent'] ?? 0,
      sos: json['sos'] ?? 0,
      sosEpoch: json['sos_epoch'] ?? 0,
      alarm: json['alarm'] ?? 0,
      journeyDurMin: json['journey_dur_min'] ?? 0,
      journeyDistMeters: json['journey_dist_meters'] ?? 0,
      journeyEtaEpoc: json['journey_eta_epoc'] ?? 0,
      passengerCount: json['passenger_count'] ?? 0,
      vtsStatus: json['vts_status'] ?? 0,
      pointsArr: pointsArr,
      startDatetimeEpoc: json['startDatetimeEpoc'] ?? 0,
      endDatetimeEpoc: json['endDatetimeEpoc'] ?? 0,
      journeyEventStr: json['journey_event_str'] ?? '',
      eventDatetimeEpoc: json['event_datetime_epoc'] ?? '0',
    );
  }
}

class JourneyPoint {
  String loc;

  JourneyPoint({
    this.loc = '',
  });

  factory JourneyPoint.fromJson(Map<String, dynamic> json) {
    return JourneyPoint(
      loc: json['loc'] ?? '',
    );
  }
}
