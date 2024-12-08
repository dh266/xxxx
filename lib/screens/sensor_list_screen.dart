import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    futureSensors = fetchSensorsByNodeId(widget.nodeId);
  }

  Future<void> _deleteSensor(int id) async {
    try {
      await deleteSensor(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sensor deleted successfully!')),
      );
      setState(() {
        futureSensors = fetchSensorsByNodeId(widget.nodeId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete sensor: $e')),
      );
    }
  }

  Future<void> _showAddSensorDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController highThresholdController = TextEditingController();
    final TextEditingController lowThresholdController = TextEditingController();
    final TextEditingController sensorTypeController = TextEditingController();
    final TextEditingController unitController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Sensor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: highThresholdController,
                  decoration: const InputDecoration(labelText: 'High Threshold'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: lowThresholdController,
                  decoration: const InputDecoration(labelText: 'Low Threshold'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sensorTypeController,
                  decoration: const InputDecoration(labelText: 'Sensor Type'),
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: const Text('Add'),
              onPressed: () async {
                try {
                  final newSensor = await createSensor(
                    Sensor(
                      id: 0, // Will be set by the server
                      name: nameController.text,
                      description: descriptionController.text,
                      nodeId: widget.nodeId,
                      highThreshold: double.parse(highThresholdController.text),
                      lowThreshold: double.parse(lowThresholdController.text),
                      sensorType: sensorTypeController.text,
                      unit: unitController.text,
                    ),
                  );
                  setState(() {
                    futureSensors = fetchSensorsByNodeId(widget.nodeId);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sensor "${newSensor.name}" created!')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create sensor: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editSensor(Sensor sensor) async {
    final TextEditingController nameController = TextEditingController(text: sensor.name);
    final TextEditingController descriptionController = TextEditingController(text: sensor.description);
    final TextEditingController highThresholdController = TextEditingController(text: sensor.highThreshold.toString());
    final TextEditingController lowThresholdController = TextEditingController(text: sensor.lowThreshold.toString());
    final TextEditingController sensorTypeController = TextEditingController(text: sensor.sensorType);
    final TextEditingController unitController = TextEditingController(text: sensor.unit);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Sensor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: highThresholdController,
                  decoration: const InputDecoration(labelText: 'High Threshold'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: lowThresholdController,
                  decoration: const InputDecoration(labelText: 'Low Threshold'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sensorTypeController,
                  decoration: const InputDecoration(labelText: 'Sensor Type'),
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  await updateSensor(
                    sensor.id,
                    Sensor(
                      id: sensor.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      nodeId: widget.nodeId,
                      highThreshold: double.parse(highThresholdController.text),
                      lowThreshold: double.parse(lowThresholdController.text),
                      sensorType: sensorTypeController.text,
                      unit: unitController.text,
                    ),
                  );
                  setState(() {
                    futureSensors = fetchSensorsByNodeId(widget.nodeId);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sensor "${sensor.name}" updated!')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update sensor: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Sensor sensor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: Text('Are you sure you want to delete "${sensor.name}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSensor(sensor.id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors'),
      ),
      body: FutureBuilder<List<Sensor>>(
        future: futureSensors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sensors = snapshot.data!;
          if (sensors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sensors_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sensors available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futureSensors = fetchSensorsByNodeId(widget.nodeId);
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sensors.length,
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sensors,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sensor.name,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    sensor.sensorType,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editSensor(sensor);
                                } else if (value == 'delete') {
                                  _showDeleteConfirmation(sensor);
                                }
                              },
                            ),
                          ],
                        ),
                        if (sensor.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            sensor.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Range: ${sensor.lowThreshold} - ${sensor.highThreshold} ${sensor.unit}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSensorDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
