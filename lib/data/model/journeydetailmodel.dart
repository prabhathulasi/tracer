class JourneyDetailsModel {
  final String journeyId;
  final List<Event>? events;
  final List<Violation>? violations;

  JourneyDetailsModel({this.journeyId = '', this.events, this.violations});

  factory JourneyDetailsModel.fromJson(Map<String, dynamic> json) {
    var elist = json['events'] as List;
    List<Event> eventList = elist.map((i) => Event.fromJson(i)).toList();

    var vlist = json['violations'] as List;
    List<Violation> violationList =
        vlist.map((i) => Violation.fromJson(i)).toList();

    return JourneyDetailsModel(
      journeyId: json['journey_id'] ?? '',
      events: eventList,
      violations: violationList,
    );
  }
}

class Event {
  final int sno;
  final int datetimeEpoc;
  final String eventStr;

  Event({this.sno = 0, this.datetimeEpoc = 0, this.eventStr = ''});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      sno: json['sno'] ?? 0,
      datetimeEpoc: json['datetime_epoc'] ?? 0,
      eventStr: json['event_str'] ?? '',
    );
  }
}

class Violation {
  final int sno;
  final int datetimeEpoc;
  final String eventStr;

  Violation({this.sno = 0, this.datetimeEpoc = 0, this.eventStr = ''});

  factory Violation.fromJson(Map<String, dynamic> json) {
    return Violation(
      sno: json['sno'] ?? 0,
      datetimeEpoc: json['datetime_epoc'] ?? 0,
      eventStr: json['event_str'] ?? '',
    );
  }
}

/*class JourneyDetailsModel {
  int c;
  int s;
  int r;
  JourneyEvents? p;
  int t;

  JourneyDetailsModel({this.c = 0, this.s = 0, this.r = 0, this.p, this.t = 0});

  factory JourneyDetailsModel.fromJson(Map<String, dynamic> json) {
    return JourneyDetailsModel(
      c: json['c'] ?? 0,
      s: json['s'] ?? 0,
      r: json['r'] ?? 0,
      p: JourneyEvents.fromJson(json['p']),
      t: json['t'] ?? 0,
    );
  }
}

class JourneyEvents {
  String journeyId;
  Map<String, dynamic>? journeyDetails;
  List<Violation>? violations;

  JourneyEvents({this.journeyId = '', this.journeyDetails, this.violations});

  factory JourneyEvents.fromJson(Map<String, dynamic> json) {
    return JourneyEvents(
      journeyId: json['journey_id'] ?? '',
      journeyDetails: json['journey_details'],
      violations: (json['violations'] as List)
          .map((violation) => Violation.fromJson(violation))
          .toList(),
    );
  }
}

class Violation {
  int sno;
  int datetimeEpoc;
  String eventStr;

  Violation({this.sno = 0, this.datetimeEpoc = 0, this.eventStr = ''});

  factory Violation.fromJson(Map<String, dynamic> json) {
    return Violation(
      sno: json['sno'] ?? 0,
      datetimeEpoc: json['datetime_epoc'] ?? 0,
      eventStr: json['event_str'] ?? '',
    );
  }
}*/
