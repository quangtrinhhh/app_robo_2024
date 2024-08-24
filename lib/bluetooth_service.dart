import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';

class BluetoothService {
  BluetoothConnection? connection;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await FlutterBluetoothSerial.instance.getBondedDevices();
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Kết nối thất bại: $e');
      return false;
    }
  }

  void sendCommand(String command) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(utf8.encode("$command\n"));
    }
  }

  void disconnect() {
    connection?.dispose();
  }
}
