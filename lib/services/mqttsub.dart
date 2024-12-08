import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientWrapper {
  final Map<String, StreamController<String>> _controllers = {};
  MqttServerClient? _client;
  bool _isConnected = false;

  Future<void> connect() async {
    if (_isConnected) return;

    _client = MqttServerClient('your.mqtt.broker.address', 'flutter_client');
    _client!.port = 1883; // Your MQTT broker port

    try {
      await _client!.connect();
      _isConnected = true;
    } catch (e) {
      print('Exception: $e');
      _client!.disconnect();
    }
  }

  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  Stream<String> getMessagesStream(String sensorId) {
    if (!_controllers.containsKey(sensorId)) {
      _controllers[sensorId] = StreamController<String>.broadcast();
      
      final topic = 'sensors/$sensorId/data';
      _client?.subscribe(topic, MqttQos.atLeastOnce);
      
      _client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
        
        if (c[0].topic == topic) {
          _controllers[sensorId]?.add(payload);
        }
      });
    }
    
    return _controllers[sensorId]!.stream;
  }
}
