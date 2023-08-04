import 'package:flutter/material.dart';
// import 'package:updater/updater.dart' as updater_lib;

import 'focusable_field.dart';

class SpecField1<T> extends StatelessWidget {
  const SpecField1({
    Key? key,
    required this.listOfT,
    // required this.updater,
    required this.titleRetriver,
    required this.defaultValue,
    required this.onTap,
    required this.fieldLabel,
    required this.fieldController,
    this.onChanged,
    this.onSubmited,
    this.enabled = true,
  }) : super(key: key);
  final List<T> listOfT;
  final T? defaultValue;
  final String Function(T) titleRetriver;
  final void Function(T) onTap;
  final bool? Function(String)? onSubmited;
  final bool? Function(String)? onChanged;
  final bool enabled;
  final TextEditingController fieldController;
  final String fieldLabel;
  // final updater_lib.Updater updater;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //  Text(
        //   fieldLabel,
        //   style: const TextStyle(
        //     fontSize: 18,
        //   ),
        // ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Stack(
              children: [
                FormField<String>(
                  enabled: enabled,
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        hintText: 'Please select expense',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        contentPadding: const EdgeInsets.all(0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<T>(
                          items: listOfT.map((e) {
                            return DropdownMenuItem<T>(
                              value: e,
                              onTap: () => onTap(e),
                              child: Text(titleRetriver(e)),
                            );
                          }).toList(),
                          value: () {
                            if (defaultValue == null) {
                              return null;
                            }
                            for (var element in listOfT) {
                              if (titleRetriver(defaultValue!) ==
                                  titleRetriver(element)) {
                                fieldController.text = titleRetriver(element);
                                return element;
                              }
                            }
                          }(),
                          onChanged: (value) {
                            // if (value == null) { return; }
                            // analysisWorkGroup =  value;
                          },
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[900],
                        ),
                        child: NFocusableField(
                          controller: fieldController,
                          node: FocusNode(),
                          enabled: enabled,
                          margin: const EdgeInsets.all(0),
                          labelTextWillBeTranslated: fieldLabel,
                          onSubmited: onSubmited ??
                              (text) {
                                FocusNode().requestFocus();
                                return true;
                              },
                          onChanged: onChanged ??
                              (text) {
                                return true;
                              },
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
