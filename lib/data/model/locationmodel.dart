class LocationModel {
  String? seq;
  String? type;
  String? lat;
  String? lon;
  String? loc;
  String? halt_dur;
  String? dist;
  String? eta;
  String? dur;
  bool isFav = false;

  LocationModel(
      {this.seq,
      this.type,
      this.lat,
      this.lon,
      this.loc,
      this.halt_dur,
      this.dist,
      this.eta,
      this.dur,
      required this.isFav});

  Map<String, dynamic> toJson() => {
        'seq': seq,
        'type': type,
        'lat': lat,
        'lon': lon,
        'loc': loc,
        'halt_dur': halt_dur,
        'dist': dist,
        'eta': eta,
        'dur': dur,
      };

  /* factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      seqid: json['id'],
      type: json['name'],
      lat: json['name'],
      lon: json['id'],
      loc: json['name'],
      haltdur: json['name'],
      dist: json['id'],
      eta: json['name'],
      dur: json['name'],
    );
  }*/
}
