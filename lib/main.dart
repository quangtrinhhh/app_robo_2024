import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async'; // Thêm thư viện dart:async để sử dụng Timer
import 'ControlPanel.dart';
import 'bluetooth_service.dart';

void main() {
  runApp(const MaterialApp(
    home: BluetoothSearchPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class BluetoothSearchPage extends StatefulWidget {
  const BluetoothSearchPage({super.key});

  @override
  _BluetoothSearchPageState createState() => _BluetoothSearchPageState();
}

class _BluetoothSearchPageState extends State<BluetoothSearchPage> {
  final BluetoothService _bluetoothService = BluetoothService();
  List<BluetoothDevice> _devices = [];
  bool _isConnecting = false;
  bool _isScanning = false;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
  }

  // Yêu cầu quyền Bluetooth từ người dùng
  Future<void> _requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    if (statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.bluetoothScan]!.isGranted) {
      _loadBondedDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần cấp quyền Bluetooth để sử dụng ứng dụng'),
        ),
      );
    }
  }

  // Tải danh sách các thiết bị Bluetooth đã ghép đôi
  Future<void> _loadBondedDevices() async {
    List<BluetoothDevice> devices = await _bluetoothService.getBondedDevices();
    setState(() {
      _devices = devices;
    });
  }

  // Quét các thiết bị Bluetooth xung quanh
  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
      _devices = []; // Xóa danh sách cũ trước khi quét mới
    });

    // Bắt đầu quét thiết bị Bluetooth
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        _devices.add(r.device);
      });
    });

    // Dừng quét sau 1 phút
    _scanTimer = Timer(const Duration(minutes: 1), () {
      _stopScan();
    });
  }

  // Hàm dừng quét
  void _stopScan() {
    _discoveryStreamSubscription?.cancel(); // Hủy luồng quét
    setState(() {
      _isScanning = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã dừng quét thiết bị')),
    );
  }

  // Kết nối với một thiết bị Bluetooth được chọn
  void _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
    });

    bool isConnected = await _bluetoothService.connectToDevice(device);
    setState(() {
      _isConnecting = false;
    });

    if (isConnected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ControlPanel(bluetoothService: _bluetoothService),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kết nối thất bại')),
      );
    }
  }

  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm thiết bị Bluetooth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _scanForDevices,
          ),
          if (_isScanning)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopScan,
            ),
        ],
      ),
      body: _isConnecting
          ? const Center(child: CircularProgressIndicator())
          : _isScanning
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Đang quét các thiết bị...'),
                    ],
                  ),
                )
              : _devices.isEmpty
                  ? const Center(child: Text('Không tìm thấy thiết bị nào'))
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        BluetoothDevice device = _devices[index];
                        return ListTile(
                          title: Text(device.name ?? 'Thiết bị không tên'),
                          subtitle: Text(device.address),
                          onTap: () => _connectToDevice(device),
                        );
                      },
                    ),
    );
  }
}
