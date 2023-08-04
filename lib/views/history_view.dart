import 'package:flutter/material.dart';
import 'package:shikat/models/ornik_model.dart';
import 'package:shikat/views/ornik_view.dart';
import 'package:shikat/views/reports_view.dart';
import 'package:shikat/widgets/focusable_field.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

List<OrnikModel> orniks = [];

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    getAwaiters();
    super.initState();
  }

  List<OrnikModel> foundOrniks = [];

  bool searchMode = false;

  Future<void> getAwaiters() async {
    // ignore: no_leading_underscores_for_local_identifiers
    var _orniks = await OrnikModel.getAll();
    orniks.clear();
    orniks.addAll(_orniks);
    setState(() {});
  }

  TextEditingController searchCont = TextEditingController();
  FocusNode searchNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العمليات السابقة'),
        backgroundColor: Colors.blueGrey,
        actions: [
          SizedBox(
            width: 350,
            child: NFocusableField(
              controller: searchCont,
              node: searchNode,
              labelTextWillBeTranslated: 'بحث',
              onChanged: (text) {
                // var r = int.tryParse(text);
                // if (r != null) {
                // } else {
                if (!searchMode) {
                  setState(() {
                    searchMode = true;
                  });
                }
                foundOrniks.clear();
                for (var ornik in orniks) {
                  if (ornik.number.toString().contains(searchCont.text) ||
                      ornik.payeeName.toString().contains(searchCont.text)) {
                    // print(ornik.number);
                    foundOrniks.add(ornik);
                  }
                }
              },
            ),
          ),
          if (searchMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    searchMode = false;
                  });
                },
              ),
            ),
        ],
      ),
      body: StreamBuilder(
          stream: !searchMode
              ? null
              : Stream.periodic(
                  const Duration(milliseconds: 100),
                ),
          builder: (context, s) {
            return GridView.builder(
              // ignore: prefer_const_constructors
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 5.5,
              ),
              itemCount: searchMode ? foundOrniks.length : orniks.length,
              itemBuilder: (context, index) {
                OrnikModel ornik;
                if (searchMode) {
                  ornik = foundOrniks[index];
                } else {
                  ornik = orniks[index];
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrnikView(
                          ornik: ornik,
                          ornikIndex: index,
                        ),
                      ),
                    ).then((value) => setState(() {}));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                ornik.number.toString(),
                                style: const TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                numberFormater(ornik.value ?? 0).toString(),
                                style: const TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Positioned(
                            top: 50,
                            child: Text(
                              (ornik.payeeName ?? 'لا يوجد إسم'),
                              style: const TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
