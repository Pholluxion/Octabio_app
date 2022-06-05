import 'package:flutter_blue/flutter_blue.dart';

class BluetoothServiceClass {
  FlutterBlue bluetoothService = FlutterBlue.instance;

  static final BluetoothServiceClass _singleton =
      BluetoothServiceClass._internal();

  factory BluetoothServiceClass() {
    return _singleton;
  }

  BluetoothServiceClass._internal();
}
