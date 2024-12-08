class Node {
  final int id;
  final String name;
  final String? description;

  Node({
    required this.id,
    required this.name,
    this.description,
  });

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}
