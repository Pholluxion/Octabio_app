import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lottie/lottie.dart';

import '../../../core/services/bluetooth_service.dart';

class ConnetBluetoothView extends StatefulWidget {
  const ConnetBluetoothView({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  State<ConnetBluetoothView> createState() => _ConnetBluetoothViewState();
}

class _ConnetBluetoothViewState extends State<ConnetBluetoothView> {
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBack(),
          _buildWidgets(_size, context),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Transform.translate(
      offset: const Offset(-60, -40),
      child: Transform.rotate(
        angle: 180,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  SingleChildScrollView _buildWidgets(Size _size, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: _size.height * 0.15),
          _imageOctabio(_size),
          _nameApp(),
          SizedBox(height: _size.height * 0.05),
          const Icon(
            Icons.bluetooth_disabled,
            size: 100.0,
            color: Colors.white,
          ),
          _btnActivar(),
        ],
      ),
    );
  }

  Padding _btnActivar() {
    final blue = BluetoothServiceClass();
    return Padding(
      padding: const EdgeInsets.only(top: 120.0, bottom: 70.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
        child: const Text('Activar Bluetooth'),
        onPressed:
            Platform.isAndroid ? () => blue.bluetoothService.turnOn() : null,
      ),
    );
  }

  Padding _nameApp() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        "Octabio",
        style: TextStyle(
          color: Colors.white,
          fontSize: 50,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Bounce _imageOctabio(Size _size) {
    return Bounce(
      infinite: true,
      duration: const Duration(seconds: 2),
      child: Padding(
        padding: EdgeInsets.only(
          right: _size.width * 0.25,
          left: _size.width * 0.25,
        ),
        child: Lottie.asset('assets/lottie/octopus.json'),
      ),
    );
  }
}
