import 'package:flutter/material.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({Key? key}) : super(key: key);

  void _handleDevicePress(BuildContext context, String device) {
    // Add your device control logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$device pressed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Device Controls',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildDeviceButton(context, 'Device 1'),
              _buildDeviceButton(context, 'Device 2'),
              _buildDeviceButton(context, 'Device 3'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceButton(BuildContext context, String deviceName) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _handleDevicePress(context, deviceName),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.power_settings_new,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              deviceName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
} 