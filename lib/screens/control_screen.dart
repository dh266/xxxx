import 'package:flutter/material.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({Key? key}) : super(key: key);

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  // Map to track the state of each device
  final Map<String, bool> _deviceStates = {
    'Device 1': false,
    'Device 2': false,
    'Device 3': false,
  };

  void _handleDevicePress(BuildContext context, String device) {
    setState(() {
      _deviceStates[device] = !_deviceStates[device]!;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${device} turned ${_deviceStates[device]! ? 'ON' : 'OFF'}',
        ),
        duration: const Duration(seconds: 1),
      ),
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
            children: _deviceStates.keys.map((deviceName) {
              final bool isActive = _deviceStates[deviceName]!;
              return _buildDeviceButton(context, deviceName, isActive);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceButton(BuildContext context, String deviceName, bool isActive) {
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
              color: isActive 
                ? Colors.green 
                : Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              deviceName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isActive 
                  ? Colors.green
                  : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isActive ? 'ON' : 'OFF',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 