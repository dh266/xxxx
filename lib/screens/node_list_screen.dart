import 'package:flutter/material.dart';
import '../models/node.dart';
import '../services/node_service.dart';
import '../screens/sensor_list_screen.dart';
import 'login_screen.dart';

class NodeListScreen extends StatefulWidget {
  const NodeListScreen({Key? key}) : super(key: key);

  @override
  State<NodeListScreen> createState() => _NodeListScreenState();
}

class _NodeListScreenState extends State<NodeListScreen> {
  late Future<List<Node>> futureNodes;

  @override
  void initState() {
    super.initState();
    futureNodes = fetchNodes();
  }

  Future<void> _deleteNode(int id) async {
    try {
      await deleteNode(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Node deleted successfully!')),
      );
      setState(() {
        futureNodes = fetchNodes();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete node: $e')),
      );
    }
  }

  Future<void> _showAddNodeDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Node'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                try {
                  final newNode = await createNode(
                    nameController.text,
                    descriptionController.text,
                  );
                  setState(() {
                    futureNodes = fetchNodes();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Node "${newNode.name}" created!')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create node: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editNode(Node node) async {
    final TextEditingController nameController =
        TextEditingController(text: node.name);
    final TextEditingController descriptionController =
        TextEditingController(text: node.description);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Node'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  await updateNode(
                    node.id,
                    nameController.text,
                    descriptionController.text,
                  );
                  setState(() {
                    futureNodes = fetchNodes();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Node "${node.name}" updated successfully!')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update node: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm chuyển đến màn hình SensorListScreen
  void _navigateToSensors(BuildContext context, int nodeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SensorListScreen(nodeId: nodeId),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Node Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddNodeDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Node>>(
        future: futureNodes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final nodes = snapshot.data!;
              if (nodes.isEmpty) {
                return const Center(
                  child: Text('No nodes available.'),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    futureNodes = fetchNodes();
                  });
                },
                child: ListView.builder(
                  itemCount: nodes.length,
                  itemBuilder: (context, index) {
                    final node = nodes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(node.name),
                        subtitle: Text(node.description ?? 'No description'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SensorListScreen(nodeId: node.id),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editNode(node),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Confirmation'),
                                    content: Text(
                                        'Are you sure you want to delete "${node.name}"?'),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ElevatedButton(
                                        child: const Text('Delete'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _deleteNode(node.id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
