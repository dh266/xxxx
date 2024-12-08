import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/sensor.dart';
import '../services/sensor_service.dart';

class SensorListScreen extends StatefulWidget {
  final int nodeId;

  const SensorListScreen({Key? key, required this.nodeId}) : super(key: key);

  @override
  State<SensorListScreen> createState() => _SensorListScreenState();
}

class _SensorListScreenState extends State<SensorListScreen> {
  late Future<List<Sensor>> futureSensors;
  late MqttServerClient client;
  final Map<int, String> sensorValues = {}; // Map lưu giá trị của cảm biến

  @override
  void initState() {
    super.initState();
    futureSensors = fetchSensorsByNodeId(widget.nodeId);

    // Chờ lấy danh sách sensors trước khi kết nối MQTT
    futureSensors.then((sensors) {
      _connectToMqtt(sensors);
    });
  }

  @override
  void dispose() {
    client.disconnect(); // Ngắt kết nối MQTT khi màn hình bị huỷ
    super.dispose();
  }

  // Kết nối MQTT và subscribe vào các topic
  Future<void> _connectToMqtt(List<Sensor> sensors) async {
    client = MqttServerClient('192.168.43.28', '');
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false);
    client.onDisconnected = _onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(
            'flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        debugPrint('MQTT connected');
        _subscribeToSensors(sensors); // Chỉ subscribe khi kết nối thành công
      } else {
        debugPrint('MQTT connection failed');
      }
    } catch (e) {
      debugPrint('MQTT connection error: $e');
    }
  }

  // Xử lý ngắt kết nối MQTT
  void _onDisconnected() {
    debugPrint('MQTT disconnected');
  }

  // Subscribe vào các topic của sensors
  Future<void> _subscribeToSensors(List<Sensor> sensors) async {
    for (var sensor in sensors) {
      final topic = 'sensors/${sensor.id}';
      client.subscribe(topic, MqttQos.atMostOnce);
      debugPrint('Subscribed to topic: $topic');
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
      if (messages != null && messages.isNotEmpty) {
        final recMessage = messages[0].payload as MqttPublishMessage;
        final topic = messages[0].topic;

        final payload = MqttPublishPayload.bytesToStringAsString(
          recMessage.payload.message,
        );

        final sensorId = int.tryParse(
          topic.split('/').where((e) => e.isNotEmpty).last,
        );

        if (sensorId != null) {
          setState(() {
            sensorValues[sensorId] = payload; // Cập nhật giá trị
          });
          debugPrint('Sensor ID: $sensorId, Value: $payload');
        } else {
          debugPrint('Failed to parse sensor ID from topic: $topic');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensors for Node ${widget.nodeId}'),
      ),
      body: FutureBuilder<List<Sensor>>(
        future: futureSensors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('No sensors available for node: ${widget.nodeId}');
            return const Center(child: Text('No sensors available.'));
          } else {
            final sensors = snapshot.data!;
            return ListView.builder(
              itemCount: sensors.length,
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                final value = sensorValues[sensor.id] ?? 'No data';
                debugPrint('Rendering sensor: ${sensor.id}, Value: $value');
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text('${sensor.name} (ID: ${sensor.id})'),
                    subtitle: Text(
                      'Value: $value${sensor.unit != null ? ' ${sensor.unit}' : ''}',
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
