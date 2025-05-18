import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectTestView extends StatefulWidget {
  const ConnectTestView({super.key});

  @override
  _ConnectTestViewState createState() => _ConnectTestViewState();
}

class _ConnectTestViewState extends State<ConnectTestView> {
  String _response = 'Waiting...';

  Future<void> callApi() async {
    final uri = Uri.parse("http://172.17.144.1:8001");
    // Use 10.0.2.2 to refer to localhost from Android emulator
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection available');
      }

      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _response = data['message'];
        });
      } else {
        setState(() {
          _response = "Failed with status: ${res.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    callApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FastAPI Test')),
      body: Center(child: Text(_response)),
    );
  }
}
