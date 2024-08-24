import "package:app_robo_2024/bluetooth_service.dart";
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class ControlPanel extends StatefulWidget {
  final BluetoothService bluetoothService;

  const ControlPanel({super.key, required this.bluetoothService});

  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nút điều khiển bên trái (Joystick)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Joystick(
                        mode: JoystickMode.all,
                        listener: (direction) {
                          double x = direction.x;
                          double y = direction.y;

                          if (x.abs() > y.abs()) {
                            if (x > 0) {
                              widget.bluetoothService.sendCommand('quay_phai');
                            } else {
                              widget.bluetoothService.sendCommand('quay_trai');
                            }
                          } else {
                            if (y > 0) {
                              widget.bluetoothService.sendCommand('lui');
                            } else {
                              widget.bluetoothService.sendCommand('tien');
                            }
                          }
                        },
                        stick: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Center(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildRoundedButton('Mở tay kẹp trái', () {
                      widget.bluetoothService.sendCommand('mo_tay_kep_trai');
                    }),
                    _buildRoundedButton('Đóng tay kẹp trái', () {
                      widget.bluetoothService.sendCommand('dong_tay_kep_trai');
                    }),
                    _buildRoundedButton('Mở tay kẹp phải', () {
                      widget.bluetoothService.sendCommand('mo_tay_kep_phai');
                    }),
                    _buildRoundedButton('Đóng tay kẹp phải', () {
                      widget.bluetoothService.sendCommand('dong_tay_kep_phai');
                    }),
                    _buildRoundedButton('Nâng tay kẹp', () {
                      widget.bluetoothService.sendCommand('nang_tay_kep');
                    }),
                    _buildRoundedButton('Hạ tay kẹp', () {
                      widget.bluetoothService.sendCommand('ha_tay_kep');
                    }),
                    _buildRoundedButton('Tắt', () {
                      widget.bluetoothService.sendCommand('tat');
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedButton(String label, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
