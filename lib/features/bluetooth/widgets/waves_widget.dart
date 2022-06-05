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
          [Colors.lightBlue, Color(0xa2d2ff)],
          [Colors.blueAccent, Color(0xa2d2ff)],
          [Colors.blue, Colors.white],
          [Colors.lightBlueAccent, Color(0x00b4d8)]
        ],
        durations: [35000, 19440, 10800, 6000],
        heightPercentages: [0.250, 0.23, 0.25, 0.30],
        blur: const MaskFilter.blur(BlurStyle.solid, 10),
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
