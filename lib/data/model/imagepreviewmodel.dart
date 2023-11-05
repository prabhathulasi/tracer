class ImagePreviewModel {
  final int id;
  final String path;
  final int datetimeEpoc;

  ImagePreviewModel({this.id = 0, this.path = '', this.datetimeEpoc = 0});

  factory ImagePreviewModel.fromJson(Map<String, dynamic> json) {
    return ImagePreviewModel(
      id: json['id'] ?? 0,
      datetimeEpoc: json['datetimeEpoc'] ?? 0,
      path: json['path'] ?? '',
    );
  }
}
