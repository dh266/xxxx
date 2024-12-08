import 'package:mqtt_client/mqtt_client.dart';
import 'dart:async';

class MqttSubscriber {
  late MqttClient client;

  late String broker = '192.168.43.28';
  late String topic;
  late String clientId = 'flutter_client';
  late int port = 1883;

  MqttSubscriber(
      {required this.broker, required this.clientId, required this.topic});

  // Hàm kết nối tới broker MQTT
  Future<void> connect() async {
    client = MqttClient.withPort(broker, clientId, port);

    // Cấu hình kết nối
    client.logging(on: true); // Bật logging để theo dõi kết nối
    client.keepAlivePeriod = 60; // Giữ kết nối với broker trong 60 giây
    client.onDisconnected = onDisconnected; // Xử lý khi kết nối bị ngắt

    try {
      print('Đang kết nối tới broker...');
      await client.connect();
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('Kết nối thành công!');
      } else {
        print('Kết nối thất bại với trạng thái: ${client.connectionStatus}');
      }
    } catch (e) {
      print('Kết nối không thành công: $e');
      client.disconnect();
    }
  }

  // Hàm subscribe vào topic và trả về messages nhận được
  Future<void> subscribeAndListen() async {
    // Đăng ký vào topic
    print('Đang subscribe vào topic: $topic');
    client.subscribe(topic, MqttQos.atMostOnce);

    // Lắng nghe các tin nhắn nhận được từ topic đã đăng ký
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage message =
          messages[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      // In ra tin nhắn nhận được
      print('Nhận tin nhắn từ topic "${messages[0].topic}": $payload');
    });
  }

  // Hàm xử lý khi mất kết nối
  void onDisconnected() {
    print('Đã bị mất kết nối với broker');
  }

  // Hàm đóng kết nối với broker
  Future<void> disconnect() async {
    print('Đang ngắt kết nối với broker...');
    client.disconnect();
  }
}
