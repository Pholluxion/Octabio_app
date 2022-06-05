import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:octabio_app/features/bluetooth/view/temperatura_view.dart';
import 'package:octabio_app/features/bluetooth/widgets/waves_widget.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              return snapshot.data == BluetoothDeviceState.connected
                  ? IconButton(
                      onPressed: () {
                        device.disconnect();
                      },
                      icon: const Icon(Icons.bluetooth_disabled_rounded),
                    )
                  : IconButton(
                      onPressed: () {
                        device.connect();
                      },
                      icon: const Icon(Icons.bluetooth_connected_rounded),
                    );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          WaveWidgetBack(),
          GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            children: <Widget>[
              _buildCard(context, Icons.thermostat),
              _buildCard(context, Icons.gamepad),
              _buildCard(context, Icons.light),
              _buildCard(context, Icons.social_distance),
              _buildCard(context, Icons.monitor_heart),
              _buildCard(context, Icons.abc),
              _buildCard(context, Icons.thermostat),
              _buildCard(context, Icons.gamepad),
              _buildCard(context, Icons.light),
              _buildCard(context, Icons.social_distance),
              _buildCard(context, Icons.monitor_heart),
              _buildCard(context, Icons.abc),
              _buildCard(context, Icons.thermostat),
              _buildCard(context, Icons.gamepad),
              _buildCard(context, Icons.light),
              _buildCard(context, Icons.social_distance),
              _buildCard(context, Icons.monitor_heart),
              _buildCard(context, Icons.abc),
            ],
          ),
        ],
      ),
    );
  }

  GestureDetector _buildCard(BuildContext context, IconData iconData) {
    return GestureDetector(
      child: Card(
        elevation: 20,
        shadowColor: Colors.black,
        child: Swing(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                iconData,
                size: 100,
                color: Colors.lightBlue,
              ),
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return TempView(device: device);
            },
          ),
        );
      },
    );
  }
}
