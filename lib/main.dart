import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const YeelightApp());
}

class YeelightApp extends StatelessWidget {
  const YeelightApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yeelight',
      theme: ThemeData(brightness: Brightness.dark),
      home: const YeelightHome(),
    );
  }
}

class YeelightHome extends StatefulWidget {
  const YeelightHome({Key? key}) : super(key: key);

  @override
  State<YeelightHome> createState() => _YeelightHomeState();
}

class _YeelightHomeState extends State<YeelightHome> {
  static const ip = "192.168.1.2";
  static const port = 55443;
  String power = 'on';
  int brightness = 50;
  String msg = 'Ready';

  Future<void> sendCmd(String method, List<dynamic> params) async {
    try {
      final sock = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      final cmd = {'id': 1, 'method': method, 'params': params};
      sock.write(jsonEncode(cmd) + '\r\n');
      sock.destroy();
    } catch (e) {
      setState(() => msg = 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('YEELIGHT', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    sendCmd('set_power', ['off', 'smooth', 500]);
                    setState(() => power = 'off');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: power == 'off' ? Colors.yellow : Colors.grey),
                  child: const Text('OFF'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    sendCmd('set_power', ['on', 'smooth', 500]);
                    setState(() => power = 'on');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: power == 'on' ? Colors.yellow : Colors.grey),
                  child: const Text('ON'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 300,
              child: Slider(
                value: brightness.toDouble(),
                min: 1,
                max: 100,
                onChanged: (val) {
                  setState(() => brightness = val.toInt());
                  sendCmd('set_bright', [val.toInt(), 'smooth', 500]);
                },
              ),
            ),
            Text('Brightness: $brightness%'),
            const SizedBox(height: 20),
            Text(msg),
          ],
        ),
      ),
    );
  }
}
