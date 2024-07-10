import 'package:flutter/material.dart';

class WriteBox extends StatelessWidget {
  const WriteBox({Key? key}) : super(key: key);
  //tenho de resolver o problema da largura
  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        
        hintText: 'username',
        border: OutlineInputBorder(),
      ),
    );
  }
}