class YoloV5Response {
  int? classLabel;
  double? confidence;
  String? name;
  double? xmax;
  double? xmin;
  double? ymax;
  double? ymin;

  YoloV5Response(
      {this.classLabel,
      this.confidence,
      this.name,
      this.xmax,
      this.xmin,
      this.ymax,
      this.ymin});

  YoloV5Response.fromJson(Map<String, dynamic> json) {
    classLabel = json['class'];
    confidence = json['confidence'];
    name = json['name'];
    xmax = json['xmax'];
    xmin = json['xmin'];
    ymax = json['ymax'];
    ymin = json['ymin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['classLabel'] = classLabel;
    data['confidence'] = confidence;
    data['name'] = name;
    data['xmax'] = xmax;
    data['xmin'] = xmin;
    data['ymax'] = ymax;
    data['ymin'] = ymin;
    return data;
  }

  @override
  String toString() {
    return 'YoloV5Response{name: $name, xmin: $xmin, ymin: $ymin, xmax: $xmax, ymax: $ymax}';
  }
}
