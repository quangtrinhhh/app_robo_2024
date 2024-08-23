import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Cố định màn hình ở chế độ nằm ngang
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(const MaterialApp(home: ControlPanel()));
  });
}

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nút điều khiển bên trái (Joystick)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sử dụng Stack để chồng vòng tròn lên joystick
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Vòng tròn bên ngoài
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Joystick
                      Joystick(
                        mode: JoystickMode.all,
                        listener: (direction) {
                          // Xử lý hướng di chuyển
                          print('Hướng: ${direction.toString()}');
                        },
                        stick: Container(
                          width: 60, // Kích thước của stick
                          height: 60, // Kích thước của stick
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
            const SizedBox(
                width: 20), // Khoảng cách giữa joystick và nút điều khiển
            // Nút điều khiển bên phải
            Expanded(
              child: Center(
                // Căn giữa GridView
                child: GridView.count(
                  crossAxisCount: 3, // 3 cột
                  mainAxisSpacing: 10, // Khoảng cách dọc
                  crossAxisSpacing: 10, // Khoảng cách ngang
                  padding: const EdgeInsets.all(20),
                  shrinkWrap:
                      true, // Giúp GridView không chiếm không gian không cần thiết
                  physics: const NeverScrollableScrollPhysics(), // Tắt cuộn
                  children: [
                    // Hàng 1
                    _buildRoundedButton('Mở tay kẹp trái', () {
                      print('Mở tay kẹp trái');
                    }),
                    _buildRoundedButton('Đóng tay kẹp trái', () {
                      print('Đóng tay kẹp trái');
                    }),
                    // Hàng 2
                    _buildRoundedButton('Mở tay kẹp phải', () {
                      print('Mở tay kẹp phải');
                    }),
                    _buildRoundedButton('Đóng tay kẹp phải', () {
                      print('Đóng tay kẹp phải');
                    }),
                    // Hàng 3
                    _buildRoundedButton('Nâng tay kẹp', () {
                      print('Nâng tay kẹp');
                    }),
                    _buildRoundedButton('Hạ tay kẹp', () {
                      print('Hạ tay kẹp');
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
        color: Colors.blue, // Màu nền nút
        borderRadius: BorderRadius.circular(15), // Bo tròn 4 góc
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors.transparent, // Màu nền của nút, sử dụng màu của Container
          shadowColor: Colors.transparent, // Không có bóng
          padding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 20), // Kích thước nút
        ),
        child: Center(
          // Căn giữa chữ
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 16, color: Colors.black), // Kích thước chữ
            textAlign: TextAlign.center, // Căn giữa chữ
          ),
        ),
      ),
    );
  }
}
