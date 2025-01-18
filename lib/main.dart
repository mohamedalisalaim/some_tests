import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _fetchPermission();
  }

  void _fetchPermission() {
    Permission.locationWhenInUse.status.then((value) {
      if (mounted) {
        setState(() {
          _hasPermission = (value == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (_hasPermission) {
            return _buildCompass();
          } else {
            return _buildPermissionSheet();
          }
        },
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        // wating
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        double? direction = snapshot.data!.heading;

        if (direction == null) {
          return const Center(
            child: Text("device deos not support compass"),
          );
        }

        return Center(
          child: Transform.rotate(
            angle: direction * (3.1415926535897932 / 180) * -1,
            child: Image.asset("lib/images/indicator.png"),
          ),
        );
      },
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Permission.locationWhenInUse.request().then((value) {
              _fetchPermission();
            });
          },
          child: const Text("Request Permission")),
    );
  }
}
