import 'package:flutter/material.dart';

class FailPage extends StatelessWidget {
  const FailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sayfa Bulunamad─▒"),
      ),
      body: Center(
        child: Column(
          children: [Text("Yok")],
        ),
      ),
    );
  }
}
