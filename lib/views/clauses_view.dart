import 'package:flutter/material.dart';
import 'package:shikat/models/statement_model.dart';
import 'package:updater/updater.dart' as updater;

import '../../widgets/focusable_field.dart';

class ClausesView extends StatefulWidget {
  const ClausesView({Key? key}) : super(key: key);

  @override
  State<ClausesView> createState() => _ClausesViewState();
}

class _ClausesViewState extends State<ClausesView> {
  List<StatementModel> models = [];
  TextEditingController titleController = TextEditingController();
  StatementModel? selectedModel;

  @override
  Widget build(BuildContext context) {
    // SystemMDBService.db.collection(RankModel.collectionName).drop();
    return Scaffold(
      appBar: AppBar(
        title: const Text('البنود'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            updater.UpdaterBlocWithoutDisposer(
              updater: ThisPageUpdater(
                init: '',
                updateForCurrentEvent: true,
              ),
              update: (context, s) {
                return Expanded(
                  child: FutureBuilder<List<StatementModel>>(
                    future: StatementModel.getAll(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'عذرا حدث خطأ ما: ${snapshot.error}',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        models = (snapshot.data!);
                        return ListView.builder(
                          itemCount: models.length,
                          itemBuilder: (context, index) {
                            var model = models[index];
                            return InkWell(
                              onTap: () {
                                selectedModel = model;
                                titleController.text = model.description;
                                ThisPageSecondUpdater().add('');
                                ThisPageUpdater().add('');
                              },
                              child: Card(
                                color: selectedModel?.mid == model.mid
                                    ? Colors.black12
                                    : null,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                  child: Row(
                                    children: [
                                      Text(model.description),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const Center(
                          child: Text(
                            'لا يوجد بيانات لعرضها',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
            updater.UpdaterBlocWithoutDisposer(
              updater: ThisPageSecondUpdater(
                init: '',
                updateForCurrentEvent: true,
              ),
              update: (context, s) {
                return SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: FocusableField(
                          titleController,
                          FocusNode(),
                          'الوصف',
                          (text) {
                            return true;
                          },
                          null,
                          null,
                          null,
                          false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 50,
                          // color: Colors.black87,
                          onPressed: selectedModel == null
                              ? null
                              : () {
                                  selectedModel!.deleteWithMID();
                                  selectedModel = null;
                                  ThisPageUpdater().add('');
                                  ThisPageSecondUpdater().add('');
                                },
                          child: const Text('حذف'),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: MaterialButton(
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     height: 50,
                      //     // color: Colors.black87,
                      //     onPressed: selectedModel == null
                      //         ? null
                      //         : () async {
                      //             if (titleController.text.isEmpty) {
                      //               return;
                      //             }

                      //             selectedModel!.description =
                      //                 titleController.text;

                      //             await selectedModel!.edit();
                      //             ThisPageUpdater().add('');
                      //             ThisPageSecondUpdater().add('');
                      //           },
                      //     child: const Text('تعديل'),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 50,
                          minWidth: 120,
                          // color: Colors.black87,
                          onPressed: () async {
                            // var analysisGroupId = ProcessesModel.stored!.requestAnalysisGroupId();
                            if (titleController.text.isEmpty) {
                              return;
                            }
                            await StatementModel(
                              0,
                              description: titleController.text,
                            ).add();
                            ThisPageUpdater().add(0);
                            ThisPageSecondUpdater().add('');
                          },
                          child: const Text('اضافة'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ThisPageUpdater extends updater.Updater {
  ThisPageUpdater({
    init,
    bool updateForCurrentEvent = false,
  }) : super(init, updateForCurrentEvent: updateForCurrentEvent);
}

class ThisPageSecondUpdater extends updater.Updater {
  ThisPageSecondUpdater({
    init,
    bool updateForCurrentEvent = false,
  }) : super(init, updateForCurrentEvent: updateForCurrentEvent);
}
