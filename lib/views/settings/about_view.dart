import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AboutView extends StatefulWidget {
  const AboutView({Key? key}) : super(key: key);

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: .0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.red,
                  highlightColor: Colors.yellow,
                  period: const Duration(seconds: 7),
                  child: const Text(
                    'BITSYSTEM',
                    style: TextStyle(
                      fontSize: 128,
                      // fontWeight: FontWeight.bold,
                      fontFamily: 'algerian',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 100,
            ),
            const Text(
              'All Rights Reserved 2023 (C)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
