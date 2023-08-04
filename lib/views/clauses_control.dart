import 'package:flutter/material.dart';

class ClauseControl extends StatefulWidget {
  const ClauseControl({super.key});

  @override
  State<ClauseControl> createState() => _ClauseControlState();
}

class _ClauseControlState extends State<ClauseControl> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('البند')),
    );
  }
}
