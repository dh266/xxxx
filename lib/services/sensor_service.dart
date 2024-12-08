import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor.dart';
import '../models/SensorData.dart';

const String baseUrl = 'http://192.168.43.107:8080/api/app/sensor';

//lấy id sensor từ node id .
Future<List<int>> fetchSensorIdsByNodeId(int nodeId) async {
  final sensors = await fetchSensorsByNodeId(nodeId);
  return sensors.map((sensor) => sensor.id).toList();
}

// Lấy danh sách Sensor theo nodeId
Future<List<Sensor>> fetchSensorsByNodeId(int nodeId) async {
  final response = await http.get(Uri.parse('$baseUrl/by-node-id/$nodeId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((json) => Sensor.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load sensors for node $nodeId');
  }
}

// Thêm Sensor mới
Future<Sensor> createSensor(Sensor sensor) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({
      'name': sensor.name,
      'description': sensor.description,
      'nodeId': sensor.nodeId,
      'highThreshold': sensor.highThreshold,
      'lowThreshold': sensor.lowThreshold,
      'sensorType': sensor.sensorType,
      'unit': sensor.unit,
    }),
  );

  if (response.statusCode == 201) {
    return Sensor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to create sensor.');
  }
}

// Sửa Sensor
Future<Sensor> updateSensor(int id, Sensor sensor) async {
  final response = await http.put(
    Uri.parse('$baseUrl/$id'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({
      'name': sensor.name,
      'description': sensor.description,
      'nodeId': sensor.nodeId,
      'highThreshold': sensor.highThreshold,
      'lowThreshold': sensor.lowThreshold,
      'sensorType': sensor.sensorType,
      'unit': sensor.unit,
    }),
  );

  if (response.statusCode == 200) {
    return Sensor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to update sensor.');
  }
}

// Xóa Sensor
Future<void> deleteSensor(int id) async {
  final response = await http.delete(Uri.parse('$baseUrl/$id'));

  if (response.statusCode != 200) {
    throw Exception('Failed to delete sensor.');
  }
}

const String sensorDataUrl = 'http://192.168.43.107:8080/api/app/sensor-data';

Future<SensorData> fetchSensorDataById(int id) async {
  final response = await http.get(Uri.parse('$sensorDataUrl/$id'));

  if (response.statusCode == 200) {
    return SensorData.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load sensor data with ID $id');
  }
}
