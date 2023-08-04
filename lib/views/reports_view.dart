import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shikat/models/ornik_model.dart';
import 'package:shikat/models/shik_model.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عرض التقارير'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              itemWidget('الشيكات'),
              itemWidget('الاورنيكات'),
            ],
          )
        ],
      ),
    );
  }

  Widget itemWidget(String reportName) {
    return InkWell(
      onTap: () {
        Get.to(
          ReportView(reportName: reportName),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          alignment: Alignment.center,
          height: 200,
          width: 200,
          child: Text(
            reportName,
            style: const TextStyle(
              fontSize: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class ReportView extends StatefulWidget {
  const ReportView({super.key, required this.reportName});
  final String reportName;

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  Widget shikWidget(ShikModel model) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  (model.payeeName).toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  (model.number).toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  (numberFormater(model.value)).toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  model.date.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('عرض تقرير ${widget.reportName}'),
        backgroundColor: Colors.blueGrey,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.abc),
          //   onPressed: () {},
          // ),
          // const SizedBox(width: 16),
          DropdownButton<SortWith>(
            items: SortWith.values
                .map(
                  (e) => DropdownMenuItem<SortWith>(
                    value: e,
                    onTap: () {
                      setState(() {
                        selectedSortWith = e;
                      });
                    },
                    child: Text(sortWithTranslations[e]),
                  ),
                )
                .toList(),
            onChanged: (v) {},
            value: selectedSortWith,
          ),
          const SizedBox(width: 32),
        ],
      ),
      body: FutureBuilder(
        future: getAndParse(),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...() {
                  List<Widget> children = [];
                  for (var index = 0; index < sorted.entries.length; index++) {
                    Widget build(MapEntry<String, List<ShikModel>> entry) =>
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${index + 1} - ${entry.key} - ${entry.value.length} شيكات',
                                  style: const TextStyle(
                                    fontSize: 38,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: entry.value
                                  .map((e) => shikWidget(e))
                                  .toList(),
                            ),
                          ],
                        );
                    children.add(build(sorted.entries.toList()[index]));
                  }
                  return children;
                }(),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, List<ShikModel>> sorted = {};

  SortWith selectedSortWith = SortWith.name;

  List<OrnikModel> orniks = [];
  List<ShikModel> cheques = [];

  bool gettedOrniks = false;

  sort() {
    sorted.clear();
    // print(cheques);
    switch (selectedSortWith) {
      case SortWith.date:
        for (var model in cheques) {
          if (sorted.containsKey(model.payeeName)) {
            sorted[model.payeeName]!.add(model);
          } else {
            sorted.addAll({
              model.payeeName: [
                model,
              ]
            });
          }
        }
        break;
      case SortWith.name:
        // print(SortWith.name);
        for (var model in cheques) {
          if (sorted.containsKey(model.payeeName)) {
            sorted[model.payeeName]!.add(model);
          } else {
            sorted.addAll({
              model.payeeName: [
                model,
              ]
            });
          }
        }
        // print(sorted);
        break;
      case SortWith.value:
        break;
      default:
    }
  }

  Future<int> getAndParse() async {
    if (gettedOrniks) {
      sort();
      return 1;
    }
    var foundModels = await OrnikModel.getAll();
    orniks.addAll(foundModels);
    for (var ornik in orniks) {
      cheques.addAll(ornik.shiks);
    }
    gettedOrniks = true;
    sort();
    return 0;
  }
}

enum SortWith {
  value,
  date,
  name,
}

Map sortWithTranslations = {
  SortWith.value: 'القيمة',
  SortWith.date: 'التاريخ',
  SortWith.name: 'الاسم',
};

String numberFormater(num number) {
  var formated = '';
  var numberToString = number.toInt().toString();
  var splited = numberToString.split('');
  var reversed = splited.reversed;
  var numsList = reversed.toList();
  var loop = 0;
  for (var index = 3; index < reversed.length; index += 3) {
    numsList.insert((index + loop), ',');
    loop++;
    // print('Formated ${numsList.reversed.join()}');
  }
  // print('Formated ${numsList.reversed.join()}');
  formated = numsList.reversed.join();
  return '$formated.0';
}
