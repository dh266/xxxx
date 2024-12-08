import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/node.dart';

// Hàm fetch danh sách Node
Future<List<Node>> fetchNodes() async {
  final response = await http.get(
    Uri.parse('http://192.168.43.107:8080/api/app/node'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> items = data['items'];
    return items
        .map((json) => Node.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load nodes');
  }
}

// Hàm để tạo Node mới
Future<Node> createNode(String name, String description) async {
  final response = await http.post(
    Uri.parse('http://192.168.43.107:8080/api/app/node'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'name': name,
      'description': description,
    }),
  );

  if (response.statusCode == 201) {
    return Node.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to create node.');
  }
}

// Hàm để xóa Node
Future<void> deleteNode(int id) async {
  final response = await http.delete(
    Uri.parse('http://192.168.43.107:8080/api/app/node/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete node.');
  }
}

// Hàm để cập nhật Node
Future<Node> updateNode(int id, String name, String description) async {
  final response = await http.put(
    Uri.parse('http://192.168.43.107:8080/api/app/node/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'name': name,
      'description': description,
    }),
  );

  if (response.statusCode == 200) {
    return Node.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to update node.');
  }
}
