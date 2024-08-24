import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ControlPanel.dart';
import 'bluetooth_service.dart';

void main() {
  runApp(const MaterialApp(home: BluetoothSearchPage()));
}

class BluetoothSearchPage extends StatefulWidget {
  const BluetoothSearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BluetoothSearchPageState createState() => _BluetoothSearchPageState();
}

class _BluetoothSearchPageState extends State<BluetoothSearchPage> {
  final BluetoothService _bluetoothService = BluetoothService();
  List<BluetoothDevice> _devices = [];
  bool _isConnecting = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
  }

  Future<void> _requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.location]!.isGranted) {
      _loadBondedDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Bạn cần cấp quyền Bluetooth và vị trí để sử dụng ứng dụng')),
      );
    }
  }

  Future<void> _loadBondedDevices() async {
    List<BluetoothDevice> devices = await _bluetoothService.getBondedDevices();
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
      _devices = []; // Xóa danh sách cũ trước khi quét mới
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        _devices.add(r.device);
      });
    }).onDone(() {
      setState(() {
        _isScanning = false;
      });
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm thiết bị Bluetooth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _scanForDevices,
          ),
        ],
      ),
      body: _isConnecting
          ? const Center(child: CircularProgressIndicator())
          : _isScanning
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Đang quét các thiết bị...'),
                  ],
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
