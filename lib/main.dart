import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:octabio_app/core/services/bluetooth_service.dart';
import 'package:octabio_app/features/bluetooth/view/connet_bluetooth_view.dart';

import 'features/bluetooth/view/search_bluetooth_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blue = BluetoothServiceClass();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<BluetoothState>(
        stream: blue.bluetoothService.state,
        initialData: BluetoothState.unknown,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return const FindDevicesScreen();
          }
          return ConnetBluetoothView(state: state);
        },
      ),
    );
  }
}
