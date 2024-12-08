class SensorData {
  final int sensorId;
  final double value;
  final String creationTime;
  final int id;

  const SensorData({
    required this.sensorId,
    required this.value,
    required this.creationTime,
    required this.id,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      sensorId: json['sensorId'] as int,
      value: (json['value'] as num).toDouble(),
      creationTime: json['creationTime'] as String,
      id: json['id'] as int,
    );
  }
}
