import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_path_upgrade/flutter_path_upgrade.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  FlutterPathUpgrade plugin = FlutterPathUpgrade();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: (){
                plugin.reStart();
              },
              child: Container(
                height: 50,
                color: Colors.black,
                child: Center(
                  child: Text(
                    '重启',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async{
                plugin.setUpgradeFile('dddddddd');
              },
              child: Container(
                height: 50,
                color: Colors.black,
                child: Center(
                  child: Text(
                    '设置so',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async{
                print(await plugin.getUpgradeFile);
              },
              child: Container(
                height: 50,
                color: Colors.black,
                child: Center(
                  child: Text(
                    '获取so',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
