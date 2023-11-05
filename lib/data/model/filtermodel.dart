class FilterModel {
  final int? id;
  final String? name;
  late bool? isFav = false;

  FilterModel({this.id, this.name, this.isFav});

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(
      id: json['id'],
      name: json['name'],
      isFav: false,
    );
  }
}
