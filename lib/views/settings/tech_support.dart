import 'package:flutter/material.dart';

class TechSupport extends StatefulWidget {
  const TechSupport({Key? key}) : super(key: key);

  @override
  State<TechSupport> createState() => _TechSupportState();
}

class _TechSupportState extends State<TechSupport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          TechSupportAppBar(),
        ],
      ),
    );
  }
}

class TechSupportAppBar extends StatelessWidget {
  const TechSupportAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Technical Support'),
        centerTitle: true,
        actions: const [],
      ),
    );
  }
}
