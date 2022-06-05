import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class WaveWidgetBack extends StatefulWidget {
  WaveWidgetBack({Key? key}) : super(key: key);

  @override
  State<WaveWidgetBack> createState() => _WaveWidgetBackState();
}

class _WaveWidgetBackState extends State<WaveWidgetBack> {
  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients: const [
          [Colors.lightBlueAccent, Color.fromARGB(0, 0, 213, 255)],
          [Colors.blueAccent, Colors.white60],
          [Colors.lightBlue, Color.fromARGB(0, 3, 175, 243)],
          [Colors.blue, Color.fromARGB(255, 102, 155, 255)],
        ],
        durations: [35000, 19440, 10800, 6000],
        heightPercentages: [0.250, 0.23, 0.25, 0.30],
        blur: const MaskFilter.blur(BlurStyle.solid, 50),
        gradientBegin: Alignment.bottomLeft,
        gradientEnd: Alignment.topRight,
      ),
      size: const Size(
        double.infinity,
        double.infinity,
      ),
    );
  }
}
