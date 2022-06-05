import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
          padding: const EdgeInsets.only(top: 250),
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
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback? onWritePressed;

  final VoidCallback onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
      required this.characteristic,
      required this.descriptorTiles,
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
          return Column(
            children: [
              Center(
                child: Text(
                  utf8.decode(value!),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IconButton(
                  //   icon: const Icon(Icons.file_download),
                  //   onPressed: onReadPressed,
                  // ),
                  IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: onWritePressed,
                  ),
                  IconButton(
                    icon: Icon(
                      characteristic.isNotifying
                          ? Icons.sync_disabled
                          : Icons.sync,
                    ),
                    onPressed: onNotificationPressed,
                  )
                ],
              ),
              descriptorTiles.first
            ],
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;

  const DescriptorTile({
    Key? key,
    required this.descriptor,
    required this.onReadPressed,
    required this.onWritePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          Text(
            '0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
          )
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.value,
        initialData: descriptor.lastValue,
        builder: (c, snapshot) => Text(snapshot.data.toString()),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.file_upload,
            ),
            onPressed: onWritePressed,
          )
        ],
      ),
    );
  }
}
