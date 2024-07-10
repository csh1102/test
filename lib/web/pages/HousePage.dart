import 'package:flutter/material.dart';

class HousePage extends StatelessWidget {
  final String homeUID;

  const HousePage({Key? key, required this.homeUID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('House Details'),
      ),
      body: Center(
        child: Text('Details for home: $homeUID'),
      ),
    );
  }
}
