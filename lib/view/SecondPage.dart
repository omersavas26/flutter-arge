import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final String? data;

  const SecondPage({Key? key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yeni Pencere"),
      ),
      body: Center(
        child: Column(
          children: [Text("YEni pencere içerik"), Text(data ?? "")],
        ),
      ),
    );
  }
}
