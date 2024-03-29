import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:lottie/lottie.dart';
import 'package:octabio_app/features/bluetooth/widgets/waves_widget.dart';

import '../widgets/service_tile_widget.dart';

const ballSize = 20.0;
const step = 10.0;

class GamePadView extends StatefulWidget {
  GamePadView({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<GamePadView> createState() => _GamePadViewState();
}

class _GamePadViewState extends State<GamePadView> {
  @override
  Widget build(BuildContext context) {
    return JoystickExample();
    // return Scaffold(
    //   appBar: AppBar(),
    //   body: Stack(children: [
    //     WaveWidgetBack(),
    //     SingleChildScrollView(
    //       child: Column(
    //         children: <Widget>[
    //           StreamBuilder<BluetoothDeviceState>(
    //             stream: widget.device.state,
    //             initialData: BluetoothDeviceState.connecting,
    //             builder: (c, snapshot) => ListTile(
    //               leading: (snapshot.data == BluetoothDeviceState.connected)
    //                   ? const Icon(
    //                       Icons.bluetooth_connected,
    //                       color: Colors.green,
    //                       size: 50,
    //                     )
    //                   : const Icon(Icons.bluetooth_disabled),
    //               title: Text(
    //                   'Octabio is ${snapshot.data.toString().split('.')[1]}.'),
    //               subtitle: Text('${widget.device.id}'),
    //               trailing: StreamBuilder<bool>(
    //                 stream: widget.device.isDiscoveringServices,
    //                 initialData: false,
    //                 builder: (c, snapshot) => IndexedStack(
    //                   index: snapshot.data! ? 1 : 0,
    //                   children: <Widget>[
    //                     IconButton(
    //                       icon: const Icon(Icons.refresh),
    //                       onPressed: () => widget.device.discoverServices(),
    //                     ),
    //                     const IconButton(
    //                       icon: SizedBox(
    //                         child: CircularProgressIndicator(
    //                           valueColor: AlwaysStoppedAnimation(Colors.grey),
    //                         ),
    //                         width: 18.0,
    //                         height: 18.0,
    //                       ),
    //                       onPressed: null,
    //                     )
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //           // StreamBuilder<List<BluetoothService>>(
    //           //   stream: widget.device.services,
    //           //   builder: (c, snapshot) {
    //           //     return Column(
    //           //       children: _buildServiceTiles(snapshot.data ?? []),
    //           //     );
    //           //   },
    //           // ),
    //         ],
    //       ),
    //     ),
    //   ]),
    // );
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

class JoystickExample extends StatefulWidget {
  const JoystickExample({Key? key}) : super(key: key);

  @override
  _JoystickExampleState createState() => _JoystickExampleState();
}

class _JoystickExampleState extends State<JoystickExample> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Joystick(
                      mode: JoystickMode.horizontal,
                      listener: (details) {
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: FittedBox(
                      child: Transform.rotate(
                          angle: pi / 2,
                          child: Lottie.asset('assets/lottie/octopus.json')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Joystick(
                      mode: JoystickMode.vertical,
                      listener: (details) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
