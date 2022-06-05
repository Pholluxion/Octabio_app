import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:octabio_app/features/bluetooth/widgets/waves_widget.dart';

class GraphView extends StatefulWidget {
  GraphView({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gráficas"),
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

class CharacteristicTile extends StatefulWidget {
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
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  final Color sinColor = Colors.redAccent;
  final Color cosColor = Colors.blue;

  final limitCount = 100;
  final sinPoints = <FlSpot>[];
  final cosPoints = <FlSpot>[];

  double xValue = 0;
  double step = 1;

  double temperature = 0;
  double humidly = 0;

  late Timer timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if ('0x${widget.characteristic.uuid.toString().toUpperCase().substring(4, 8)}' ==
        "0xFFE1") {
      return StreamBuilder<List<int>>(
        stream: widget.characteristic.value,
        initialData: widget.characteristic.lastValue,
        builder: (c, snapshot) {
          final value = snapshot.data;

          timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            while (sinPoints.length > limitCount) {
              sinPoints.removeAt(0);
              cosPoints.removeAt(0);
            }
          });

          if (value!.isNotEmpty) {
            sinPoints.add(FlSpot(
                xValue.round().toDouble(),
                double.parse(utf8
                        .decode(value)
                        .trim()
                        .split('-')[0]
                        .replaceAll("<", ""))
                    .round()
                    .toDouble()));
            cosPoints.add(FlSpot(
                xValue.round().toDouble(),
                double.parse(utf8
                        .decode(value)
                        .trim()
                        .split('-')[1]
                        .replaceAll(">", ""))
                    .round()
                    .toDouble()));
          }

          xValue += step;
          return value.isNotEmpty
              ? Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 800,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          minX: sinPoints.first.x,
                          maxX: sinPoints.last.x,
                          lineTouchData: LineTouchData(enabled: false),
                          clipData: FlClipData.all(),
                          backgroundColor: Colors.white,
                          lineBarsData: [
                            sinLine(sinPoints),
                            cosLine(cosPoints),
                          ],
                          titlesData: FlTitlesData(
                            show: false,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Temperatura [ °C ] ${sinPoints.last.y.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: sinColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Humedad [ % ] ${cosPoints.last.y.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: cosColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    )
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

  LineChartBarData sinLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      barWidth: 4,
      color: sinColor,
      isCurved: false,
    );
  }

  LineChartBarData cosLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      color: cosColor,
      barWidth: 4,
      isCurved: false,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
