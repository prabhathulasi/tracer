class Driver {
  final int? id;
  final String? name;
  final int? status;
  final String? statusStr;
  final List<Compliance>? compliance;

  Driver({this.id, this.name, this.status, this.statusStr, this.compliance});

  factory Driver.fromJson(Map<String, dynamic> json) {
    var list = json['compliance'] as List;
    List<Compliance> complianceList =
        list.map((i) => Compliance.fromJson(i)).toList();

    return Driver(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      statusStr: json['status_str'],
      compliance: complianceList,
    );
  }
}

class Compliance {
  final String? name;
  final String? doe;
  final int? status;
  final String? statusStr;

  Compliance({this.name, this.doe, this.status, this.statusStr});

  factory Compliance.fromJson(Map<String, dynamic> json) {
    return Compliance(
      name: json['name'],
      doe: json['doe'],
      status: json['status'],
      statusStr: json['status_str'],
    );
  }
}
