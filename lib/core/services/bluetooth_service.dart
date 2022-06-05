import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothServiceClass {
  FlutterBluePlus bluetoothService = FlutterBluePlus.instance;

  static final BluetoothServiceClass _singleton =
      BluetoothServiceClass._internal();

  factory BluetoothServiceClass() {
    return _singleton;
  }

  BluetoothServiceClass._internal();
}
