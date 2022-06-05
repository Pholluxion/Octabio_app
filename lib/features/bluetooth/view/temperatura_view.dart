import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:octabio_app/features/bluetooth/widgets/waves_widget.dart';

import '../widgets/service_tile_widget.dart';

class TempView extends StatefulWidget {
  TempView({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<TempView> createState() => _TempViewState();
}

class _TempViewState extends State<TempView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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

              // StreamBuilder<int>(
              //   stream: device.mtu,
              //   initialData: 0,
              //   builder: (c, snapshot) => ListTile(
              //     title: const Text('MTU Size'),
              //     subtitle: Text('${snapshot.data} bytes'),
              //     trailing: IconButton(
              //       icon: const Icon(Icons.edit),
              //       onPressed: () => device.requestMtu(223),
              //     ),
              //   ),
              // ),

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
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTile(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                            onWritePressed: () => d.write([0x12, 0x34]),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }
}
