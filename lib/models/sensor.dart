class Sensor {
  final int id;
  final String name;
  final String? description;
  final int nodeId;
  final double highThreshold;
  final double lowThreshold;
  final int sensorType;
  final String? unit;

  Sensor({
    required this.id,
    required this.name,
    this.description,
    required this.nodeId,
    required this.highThreshold,
    required this.lowThreshold,
    required this.sensorType,
    this.unit,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      nodeId: json['nodeId'] as int,
      highThreshold: (json['highThreshold'] as num).toDouble(),
      lowThreshold: (json['lowThreshold'] as num).toDouble(),
      sensorType: json['sensorType'] as int,
      unit: json['unit'] as String?,
    );
  }
}
