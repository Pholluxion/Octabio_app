import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:octabio_app/features/bluetooth/view/device_home_view.dart';
import 'package:octabio_app/features/bluetooth/widgets/waves_widget.dart';

import '../../../core/services/bluetooth_service.dart';
import '../widgets/scan_result_widget.dart';

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  final blue = BluetoothServiceClass();
  @override
  void initState() {
    blue.bluetoothService.startScan(
      timeout: const Duration(seconds: 10),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuentra tu Octabio!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_disabled_rounded),
            onPressed: Platform.isAndroid
                ? () {
                    blue.bluetoothService.turnOff();
                  }
                : null,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          WaveWidgetBack(),
          RefreshIndicator(
            onRefresh: () => blue.bluetoothService.startScan(
              timeout: const Duration(seconds: 4),
            ),
            child: Stack(children: [
              _imageOctabio(size),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _showConnectedDevice(blue, context),
                    _showDevices(blue, context),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: _showButtons(blue),
    );
  }

  Widget _imageOctabio(Size _size) {
    return Padding(
      padding: EdgeInsets.only(
        top: _size.height * 0.4,
        right: _size.width * 0.3,
        left: _size.width * 0.3,
      ),
      child: Image.asset(
        "assets/img/logo.png",
      ),
    );
  }

  StreamBuilder<bool> _showButtons(BluetoothServiceClass blue) {
    return StreamBuilder<bool>(
      stream: blue.bluetoothService.isScanning,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.data!) {
          return FloatingActionButton(
            child: const Icon(Icons.stop),
            onPressed: () => blue.bluetoothService.stopScan(),
            backgroundColor: Colors.red,
          );
        } else {
          return FloatingActionButton(
            child: const Icon(Icons.search),
            onPressed: () => blue.bluetoothService.startScan(
              timeout: const Duration(seconds: 10),
            ),
            backgroundColor: Colors.green,
          );
        }
      },
    );
  }

  StreamBuilder<List<ScanResult>> _showDevices(
      BluetoothServiceClass blue, BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: blue.bluetoothService.scanResults,
      initialData: const [],
      builder: (context, snapshot) {
        return Column(
          children: snapshot.data!.map(
            (result) {
              if (result.device.name.contains("octabio")) {
                return ScanResultTile(
                  result: result,
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          result.device.connect();
                          return DeviceScreen(device: result.device);
                        },
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ).toList(),
        );
      },
    );
  }

  StreamBuilder<List<BluetoothDevice>> _showConnectedDevice(
      BluetoothServiceClass blue, BuildContext context) {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: Stream.periodic(const Duration(seconds: 2))
          .asyncMap((_) => blue.bluetoothService.connectedDevices),
      initialData: const [],
      builder: (c, snapshot) => Column(
        children: snapshot.data!
            .map(
              (device) => ListTile(
                leading: const Icon(
                  Icons.bluetooth_connected_rounded,
                  color: Colors.green,
                  size: 40,
                ),
                title: Text(device.name),
                subtitle: Text(device.id.toString()),
                trailing: StreamBuilder<BluetoothDeviceState>(
                  stream: device.state,
                  initialData: BluetoothDeviceState.disconnected,
                  builder: (c, snapshot) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        padding: const EdgeInsets.only(
                          left: 27,
                          right: 27,
                        ),
                      ),
                      child: const Text('Abrir'),
                      onPressed: () {
                        blue.bluetoothService.turnOn();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DeviceScreen(device: device),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
