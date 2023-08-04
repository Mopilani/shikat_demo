import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shikat/views/clauses_view.dart';
import 'package:shikat/views/companies_view.dart';
import 'package:shikat/views/history_view.dart';
import 'package:shikat/views/ornik_view.dart';
import 'package:shikat/views/reports_view.dart';
import 'package:shikat/views/settings/settings.dart';
import 'package:shimmer/shimmer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool shimmerEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HomePageAppBar(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      shimmerEnabled = !shimmerEnabled;
                    });
                  },
                  child: Shimmer.fromColors(
                    baseColor: Colors.blue,
                    highlightColor: Colors.red,
                    period: const Duration(seconds: 7),
                    direction: ShimmerDirection.rtl,
                    enabled: shimmerEnabled,
                    child: const Text(
                      'ألإدارة ألعامة للشرطة ألمجتمعية',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    bigItemWidget('اورنيك جديد', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrnikView(),
                        ),
                      );
                    }),
                    bigItemWidget('العمليات السابقة', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryView(),
                        ),
                      );
                    }),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    smallItemWidget('البنود', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClausesView(),
                        ),
                      );
                    }),
                    smallItemWidget('الشركات', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompaniesView(),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector bigItemWidget(String title, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 300,
        height: 200,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector smallItemWidget(String title, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        height: 150,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePageAppBar extends StatelessWidget {
  const HomePageAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('BITSYSTEM Businet Chekat'),
        // centerTitle: true,
        actions: [
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              // Get.to(const ReportsView());
              Get.to(const ReportView(reportName: 'الشيكات'));
            },
            icon: const Icon(Icons.content_paste_go_rounded),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              Get.to(const SettingsView());
            },
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(width: 16),
        ],
        // leading: const SizedBox(),
      ),
    );
  }
}
