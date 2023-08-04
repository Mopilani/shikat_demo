import 'dart:io';

import '/models/system_config.dart';
import '/utils/check_funcs.dart';
import '/utils/sync_service.dart';
import 'package:flutter/material.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:overlay_support/overlay_support.dart';
import '/views/settings/database_settings.dart';
import 'package:updater/updater.dart' as updater;

class WindowsPrinting {
  static Future<String?> getAvailablePrintersNames() async {
    try {
      final process = await Process.run('printing/raw_print_helper.exe', [
        'showprinters',
      ]);
      return process.stdout;
    } catch (e) {
      // print(e);
      return null;
    }
  }
}

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  List<String> panamas = []; // Printers List
  List<String> svnamas = []; // Printers List
  List<String> pageRoutingTypes = [
    'CupertinoPageRoute',
    'MaterialPageRoute',
  ];

  @override
  void initState() {
    super.initState();
  }

  // printerChoosDialog() {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Material(
  //         color: Colors.transparent,
  //         child: GestureDetector(
  //           onTap: () => Navigator.pop(context),
  //           child: Container(
  //             alignment: Alignment.center,
  //             color: Colors.transparent,
  //             height: 300,
  //             width: 300,
  //             child: GestureDetector(
  //               onTap: () {},
  //               child: SizedBox(
  //                 height: 300,
  //                 width: 300,
  //                 child: Card(
  //                   color: Colors.white,
  //                   child: Center(
  //                     child: Column(
  //                       children: [
  //                         Container(
  //                           padding: const EdgeInsets.all(16),
  //                           margin: const EdgeInsets.all(16),
  //                           color: Colors.black,
  //                           child: Text(
  //                             'Printer List',
  //                             style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                         for (String printerName in _printerList)
  //                           MaterialButton(
  //                             onPressed: () {
  //                               ProcessesModel.stored!.printerName =
  //                                   printerName;
  //                               ProcessesModel.stored!.edit();
  //                             },
  //                             child: Text('$printerName\n'),
  //                           )
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(
        const Duration(milliseconds: 200),
      ),
      builder: (context, snapshot) {
        return Scaffold(
          body: Column(
            children: [
              const GeneralSettingsAppBar(),
              // Container(
              //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              //   child: ListTile(
              //     onTap: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const DatabaseSettings(),
              //         ),
              //       );
              //     },
              //     leading: const Icon(Icons.library_books),
              //     title: const Text('Database'),
              //     subtitle: const Text('Categories and so..'),
              //   ),
              // ),
              // Container(
              //   // height: 80,
              //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              //   child: CheckboxListTile(
              //     onChanged: (v) {
              //       setState(() {
              //         SystemConfig().animations = !SystemConfig().animations;
              //       });
              //     },
              //     value: SystemConfig().animations,
              //     // leading: const Icon(Icons.book),
              //     title: const Text('الرسوم المتحركة'),
              //     subtitle:
              //         Text(SystemConfig().animations ? "تعمل" : "لا تعمل"),
              //   ),
              // ),
              // Container(
              //   // height: 80,
              //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              //   child: CheckboxListTile(
              //     onChanged: (v) {
              //       setState(() {
              //         SystemConfig().runSyncService =
              //             !SystemConfig().runSyncService;
              //       });
              //     },
              //     value: SystemConfig().runSyncService,
              //     // leading: const Icon(Icons.book),
              //     title: const Text('خدمة المزامنة'),
              //     // subtitle: const Text('مزامنة البيانات عبر الشبكة'),
              //     subtitle:
              //         Text(SystemConfig().runSyncService ? "تعمل" : "لا تعمل"),
              //   ),
              // ),
              // ListTile(
              //   title: const Text('نوع الخادم'),
              //   leading: const Icon(Icons.format_list_numbered),
              //   trailing: DropdownButton<DeviceOnNetType>(
              //     value: deviceOnNetType,
              //     onChanged: (t) async {
              //       if (t == null) return;
              //       deviceOnNetType = t;
              //       SystemConfig.stored!.deviceOnNetType = deviceOnNetType;
              //     },
              //     items: const [
              //       DropdownMenuItem(
              //         value: DeviceOnNetType.master,
              //         child: Text('رئيسي'),
              //       ),
              //       DropdownMenuItem(
              //         value: DeviceOnNetType.slave,
              //         child: Text('فرعي'),
              //       ),
              //       DropdownMenuItem(
              //         value: DeviceOnNetType.slaveMaster,
              //         child: Text('فرعي - نائب'),
              //       ),
              //     ],
              //   ),
              //   // onTap: () async {},
              // ),
              ListTile(
                title: const Text('اختيار الطابعة'),
                leading: const Icon(
                  Icons.print,
                ),
                trailing: Text(SystemConfig().printer.toString()),
                onTap: () async {
                  panamas = ((await WindowsPrinting.getAvailablePrintersNames())
                          as String)
                      .split(',');
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Scaffold(
                        body: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...panamas
                                  .map(
                                    (e) => ListTile(
                                      title: Text(e),
                                      onTap: () async {
                                        // final box = await Hive.openBox('data');
                                        setState(() {
                                          SystemConfig().printer = e;
                                        });
                                        // await box
                                        //     .put('defPrntr', SystemConfig.printer)
                                        //     .then((value) {
                                        Navigator.pop(context);
                                        // });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // ListTile(
              //   title: const Text('Page Routings'),
              //   leading: const Icon(
              //     Icons.route,
              //   ),
              //   trailing: Text(SystemConfig().pageRoute.toString()),
              //   onTap: () async {
              //     showModalBottomSheet(
              //       context: context,
              //       builder: (context) {
              //         return Scaffold(
              //           body: SingleChildScrollView(
              //             child: Column(
              //               children: [
              //                 ...pageRoutingTypes
              //                     .map(
              //                       (e) => ListTile(
              //                         title: Text(e),
              //                         onTap: () async {
              //                           setState(() {
              //                             SystemConfig().pageRoute = e;
              //                           });
              //                           Navigator.pop(context);
              //                         },
              //                       ),
              //                     )
              //                     .toList(),
              //               ],
              //             ),
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),
              // ListTile(
              //   title: const Text('نظام شاشة البيع'),
              //   trailing: DropdownButton<String>(
              //     value: SystemConfig().salesType,
              //     items: const [
              //       DropdownMenuItem<String>(
              //         value: InterfaceType.administration,
              //         child: Text(InterfaceType.administration),
              //       ),
              //       DropdownMenuItem<String>(
              //         value: InterfaceType.lab,
              //         child: Text(InterfaceType.lab),
              //       ),
              //       DropdownMenuItem<String>(
              //         value: InterfaceType.pharmacy,
              //         child: Text(InterfaceType.pharmacy),
              //       ),
              //       DropdownMenuItem<String>(
              //         value: InterfaceType.reception,
              //         child: Text(InterfaceType.reception),
              //       ),
              //     ],
              //     onChanged: (value) {
              //       if (value != null) {
              //         setState(() {
              //           SystemConfig().salesType = value;
              //         });
              //       }
              //     },
              //   ),
              // ),
              // Container(
              //   // height: 80,
              //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              //   child: ListTile(
              //     onTap: () {},
              //     leading: const Icon(Icons.print_rounded),
              //     title: const Text('Default Printer'),
              //     subtitle: Text(
              //       'Current: ${SystemConfig.printer ?? 'Default Printer Not Defiend, We can' "'" 't find any available printers'}',
              //     ),
              //   ),
              // ),
              Container(
                // height: 80,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: ListTile(
                  onTap: onTapInvoicesSavingFolder,
                  leading: const Icon(Icons.folder),
                  title: const Text('Invoices Saving Folder'),
                  subtitle: Text(
                      'Current: ${SystemConfig().invoicesSaveDirectoryPath}'),
                ),
              ),
              // farDevicesControlWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget farDevicesControlWidget() {
    Future<void> addSvNamas(String value) async {
      SystemConfig.stored!.addSv = value;
      SettingsFarDevicesBottomSheetUpdater().add('');
    }

    Future<void> removeSvNamas(value) async {
      SystemConfig.stored!.removeSv = value;
      SettingsFarDevicesBottomSheetUpdater().add('');
    }

    if (Platform.isAndroid) {
      return const SizedBox();
    } else {
      return ListTile(
        title: const Text('الاجهزة البعيدة'),
        leading: const Icon(Icons.polyline),
        onTap: () async {
          svnamas = [...(SystemConfig.stored!.svnamas!)];
          showModalBottomSheet(
            context: context,
            builder: (context) {
              TextEditingController crntController = TextEditingController();
              return Scaffold(
                body: SingleChildScrollView(
                  child: updater.UpdaterBloc(
                    updater: SettingsFarDevicesBottomSheetUpdater(
                      updateForCurrentEvent: true,
                      initialState: 0,
                    ),
                    update: (context, state) {
                      return Column(
                        children: [
                          ListTile(
                            title: TextField(
                              controller: crntController,
                              onSubmitted: (text) async =>
                                  await addSvNamas(text),
                              decoration: const InputDecoration(
                                hintText: '192.168.0.11',
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () async =>
                                  await addSvNamas(crntController.text),
                            ),
                          ),
                          ...svnamas
                              .map(
                                (e) => ListTile(
                                  title: Text(
                                    e,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () async =>
                                        await removeSvNamas(e),
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  void onTapInvoicesSavingFolder() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(10),
      // ),
      context: context,
      builder: (context) {
        TextEditingController cont = TextEditingController(
          text: SystemConfig().invoicesSaveDirectoryPath,
        );
        return Container(
          height: 200,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              TextField(
                controller: cont,
                onSubmitted: (String input) async {
                  if (await chkdir(input)) {
                    SystemConfig().invoicesSaveDirectoryPath = input;
                    Navigator.pop(context);
                    setState(() {});
                  } else {
                    toast("We can't find the specified directory");
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GeneralSettingsAppBar extends StatelessWidget {
  const GeneralSettingsAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Account Settings'),
        centerTitle: true,
        actions: const [],
      ),
    );
  }
}

class SettingsFarDevicesBottomSheetUpdater extends updater.Updater {
  SettingsFarDevicesBottomSheetUpdater({
    initialState,
    bool updateForCurrentEvent = false,
  }) : super(
          initialState,
          updateForCurrentEvent: updateForCurrentEvent,
        );
}
