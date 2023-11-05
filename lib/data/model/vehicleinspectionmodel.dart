class VehicleInspectionModel {
  final String c;
  final int s;
  final int r;
  final InspectionPayload p;
  final dynamic t;

  VehicleInspectionModel(
      {this.c = "", this.s = 0, this.r = 0, required this.p, this.t});

  factory VehicleInspectionModel.fromJson(Map<String, dynamic> json) {
    return VehicleInspectionModel(
      c: json['c'] ?? "",
      s: json['s'] ?? 0,
      r: json['r'] ?? 0,
      p: InspectionPayload.fromJson(json['p']),
      t: json['t'],
    );
  }
}

class InspectionPayload {
  List<ImageData> pointsArr;

  InspectionPayload({
    this.pointsArr = const [],
  });

  factory InspectionPayload.fromJson(Map<String, dynamic> json) {
    List<ImageData> pointsArr = [];
    if (json.containsKey('img_arr')) {
      var list = json['img_arr'] as List;
      pointsArr = list.map((i) => ImageData.fromJson(i)).toList();
    }
    return InspectionPayload(
      pointsArr: pointsArr,
    );
  }
}

class ImageData {
  int id;
  int sno;
  String path;
  int datetimeEpoc;
  String? datetime;
  bool? imageUploaded;
  bool? alreadyUploaded;

  ImageData(
      {this.id = 0,
      this.sno = 0,
      this.path = '',
      this.datetime,
      this.datetimeEpoc = 0,
      this.imageUploaded = false,
      this.alreadyUploaded = true});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
        datetime: json["datetime"],
        id: json['id'] ?? 0,
        path: json['path'] ?? '',
        datetimeEpoc: json['datetime_epoc'] ?? 0);
  }
}
 /* int? sno;
  String? imagePath;
  bool? imageUploaded;
  String? datetime;

  VehicleInspectionModel(
      {this.sno = 0,
      this.imagePath = '',
      this.imageUploaded = true,
      this.datetime = ''});

  factory VehicleInspectionModel.fromJson(Map<String, dynamic> json) {
    return VehicleInspectionModel(
      sno: json['sno'],
      imagePath: json['value'],
      imageUploaded: json['label'],
    );
  }
}*/
