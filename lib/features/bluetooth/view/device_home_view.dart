import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:octabio_app/features/bluetooth/view/gamepad_view.dart';
import 'package:octabio_app/features/bluetooth/view/graph_view.dart';
import 'package:octabio_app/features/bluetooth/view/humidly_view.dart';
import 'package:octabio_app/features/bluetooth/view/motion_view.dart';
import 'package:octabio_app/features/bluetooth/view/proximity_view.dart';
import 'package:octabio_app/features/bluetooth/view/temperatura_view.dart';
import 'package:octabio_app/features/bluetooth/widgets/waves_widget.dart';

class DeviceHomeView extends StatelessWidget {
  const DeviceHomeView({Key? key, required this.device}) : super(key: key);

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
            padding: const EdgeInsets.all(20),
            primary: false,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: <Widget>[
              _buildCard(
                  context, 'assets/lottie/temp.json', TempView(device: device)),
              _buildCard(context, 'assets/lottie/humidly.json',
                  HumidlyView(device: device)),
              _buildCard(context, 'assets/lottie/game.json',
                  GamePadView(device: device)),
              _buildCard(context, 'assets/lottie/radar.json',
                  ProximityView(device: device)),
              _buildCard(context, 'assets/lottie/motion.json',
                  MotionView(device: device)),
              _buildCard(context, 'assets/lottie/graph.json',
                  GraphView(device: device)),
            ],
          ),
        ],
      ),
    );
  }

  GestureDetector _buildCard(BuildContext context, String label, Widget view) {
    return GestureDetector(
      child: JelloIn(
        duration: const Duration(milliseconds: 700),
        child: Card(
          elevation: 5,
          color: Colors.transparent,
          borderOnForeground: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          shadowColor: Colors.white24,
          child: Lottie.asset(label, width: 100),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return view;
            },
          ),
        );
      },
    );
  }
}
