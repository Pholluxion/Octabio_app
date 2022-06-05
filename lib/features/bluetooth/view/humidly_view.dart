import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:octabio_app/features/bluetooth/widgets/waves_widget.dart';

class HumidlyView extends StatefulWidget {
  HumidlyView({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<HumidlyView> createState() => _HumidlyViewState();
}

class _HumidlyViewState extends State<HumidlyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Humedad"),
      ),
      body: Stack(children: [
        WaveWidgetBack(),
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<BluetoothDeviceState>(
                stream: widget.device.state,
                initialData: BluetoothDeviceState.connecting,
                builder: (c, snapshot) => ListTile(
                  leading: (snapshot.data == BluetoothDeviceState.connected)
                      ? const Icon(
                          Icons.bluetooth_connected,
                          color: Colors.green,
                          size: 50,
                        )
                      : const Icon(Icons.bluetooth_disabled),
                  title: Text(
                      'Octabio is ${snapshot.data.toString().split('.')[1]}.'),
                  subtitle: Text('${widget.device.id}'),
                  trailing: StreamBuilder<bool>(
                    stream: widget.device.isDiscoveringServices,
                    initialData: false,
                    builder: (c, snapshot) => IndexedStack(
                      index: snapshot.data! ? 1 : 0,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => widget.device.discoverServices(),
                        ),
                        const IconButton(
                          icon: SizedBox(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.grey),
                            ),
                            width: 18.0,
                            height: 18.0,
                          ),
                          onPressed: null,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              StreamBuilder<List<BluetoothService>>(
                stream: widget.device.services,
                builder: (c, snapshot) {
                  return Column(
                    children: _buildServiceTiles(snapshot.data ?? []),
                  );
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    characteristic: c,
                    onNotificationPressed: () async {
                      await c.setNotifyValue(!c.isNotifying);
                      await c.read();
                    },
                    onWritePressed: () async {
                      try {
                        await c.write([0x12, 0x34], withoutResponse: false);
                        await c.read();
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {Key? key, required this.service, required this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.isNotEmpty &&
        '0x${service.uuid.toString().toUpperCase().substring(4, 8)}' ==
            '0xFFE0') {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: characteristicTiles[0],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;

  final VoidCallback? onWritePressed;

  final VoidCallback onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
      required this.characteristic,
      required this.onNotificationPressed,
      this.onWritePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}' ==
        "0xFFE1") {
      return StreamBuilder<List<int>>(
        stream: characteristic.value,
        initialData: characteristic.lastValue,
        builder: (c, snapshot) {
          final value = snapshot.data;
          // print(utf8.decode(value!));

          return value!.isNotEmpty
              ? Column(
                  children: [
                    Lottie.asset('assets/lottie/humidly.json', width: 250),

                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Center(
                        child: FittedBox(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                utf8
                                    .decode(value)
                                    .trim()
                                    .split('-')[1]
                                    .replaceAll(">", ""),
                                style: const TextStyle(
                                  fontSize: 80,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 30,
                                      color: Colors.black,
                                    )
                                  ],
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const Text(
                                " % ",
                                style: TextStyle(
                                  fontSize: 80,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 30,
                                      color: Colors.black,
                                    )
                                  ],
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        characteristic.isNotifying
                            ? Icons.sync_disabled
                            : Icons.sync,
                        size: 50,
                        color: Colors.white,
                      ),
                      onPressed: onNotificationPressed,
                    )

                    // descriptorTiles.first
                  ],
                )
              : const Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
