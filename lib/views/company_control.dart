import 'package:flutter/material.dart';

class CompanyControl extends StatefulWidget {
  const CompanyControl({super.key});

  @override
  State<CompanyControl> createState() => _CompanyControlState();
}

class _CompanyControlState extends State<CompanyControl> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الشركة')),
    );
  }
}
