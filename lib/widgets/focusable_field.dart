import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class FocusableField extends StatelessWidget {
  const FocusableField(this.controller, this.node,
      this.labelTextWillBeTranslated, this.onSubmited,
      [this.nextNode,
      this.nextController,
      this.whatToSayifIsEmpty,
      this.isNumber = false,
      this.isDouble = false,
      this.canBeNegative = false,
      this.enabled = true,
      this.reFocusIfEmptey = true,
      Key? key])
      : super(key: key);

  final TextEditingController controller;
  final FocusNode node;
  final String labelTextWillBeTranslated;
  final FutureOr<bool?> Function(String) onSubmited;
  final FocusNode? nextNode;
  final TextEditingController? nextController;
  final String? whatToSayifIsEmpty;
  final bool isNumber;
  final bool isDouble;
  final bool enabled;
  final bool canBeNegative;
  final bool reFocusIfEmptey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
        child: TextField(
          controller: controller,
          enabled: enabled,
          focusNode: node,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            labelText: labelTextWillBeTranslated.tr(),
          ),
          onSubmitted: (result) async {
            if (whatToSayifIsEmpty != null) {
              if (result.isEmpty) {
                showSimpleNotification(
                  Text(whatToSayifIsEmpty!),
                  position: NotificationPosition.bottom,
                );
                if (reFocusIfEmptey) {
                  node.requestFocus();
                }
                return;
              }
            }
            if (isNumber) {
              try {
                if (int.parse(result).isNegative != canBeNegative) {
                  showSimpleNotification(
                    const Text('عذرا الرقم صغير جدا'),
                    position: NotificationPosition.bottom,
                  );
                  return;
                }
              } catch (e) {
                showSimpleNotification(
                  const Text(
                      ' تأكد من كتابتك للرقم بصورة صحيحة حيث يحتوي على ارقام فقط وليس به فاصلة'),
                  position: NotificationPosition.bottom,
                );
                return;
              }
            }
            if (isDouble) {
              try {
                if (double.parse(result).isNegative != canBeNegative) {
                  showSimpleNotification(
                    const Text('عذرا الرقم صغير جدا'),
                    position: NotificationPosition.bottom,
                  );
                  return;
                }
              } catch (e) {
                showSimpleNotification(
                  const Text(
                      'تأكد من كتابتك للرقم بصورة صحيحة حيث يحتوي على ارقام فقط'),
                  position: NotificationPosition.bottom,
                );
                return;
              }
            }
            var r = await onSubmited(result);
            if (r == null || r) {
              nextNode?.requestFocus();
              nextController?.selection = TextSelection(
                baseOffset: 0,
                extentOffset: nextController!.text.length,
              );
            } else {
              node.requestFocus();
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            }
          },
        ),
      ),
    );
  }
}

class NFocusableField extends StatelessWidget {
  const NFocusableField({
    required this.controller,
    required this.node,
    required this.labelTextWillBeTranslated,
    this.onSubmited,
    this.onChanged,
    this.maxLength,
    this.nextNode,
    this.nextController,
    this.whatToSayifIsEmpty,
    this.isNumber = false,
    this.isDouble = false,
    this.canBeNegative = false,
    this.enabled = true,
    this.reFocusIfEmptey = true,
    this.maxLines = 1,
    this.minLines,
    this.prefix,
    this.margin,
    this.style,
    this.suffix,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode node;
  final Widget? prefix;
  final Widget? suffix;
  final String labelTextWillBeTranslated;
  final TextStyle? style;
  final FutureOr<bool?> Function(String)? onSubmited;
  final Function(String)? onChanged;
  final FocusNode? nextNode;
  final TextEditingController? nextController;
  final String? whatToSayifIsEmpty;
  final bool isNumber;
  final bool isDouble;
  final bool enabled;
  final bool canBeNegative;
  final bool reFocusIfEmptey;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        margin: margin ??
            const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
        child: TextField(
          controller: controller,
          enabled: enabled,
          focusNode: node,
          maxLines: maxLines,
          style: style,
          minLines: minLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            suffix: suffix,
            prefix: prefix,
            contentPadding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            labelText: labelTextWillBeTranslated.tr(),
          ),
          onChanged: onChanged,
          onSubmitted: (result) async {
            if (whatToSayifIsEmpty != null) {
              if (result.isEmpty) {
                showSimpleNotification(
                  Text(whatToSayifIsEmpty!),
                  position: NotificationPosition.bottom,
                );
                if (reFocusIfEmptey) {
                  node.requestFocus();
                }
                return;
              }
            }
            if (isNumber) {
              try {
                if (int.parse(result).isNegative != canBeNegative) {
                  showSimpleNotification(
                    const Text('عذرا الرقم صغير جدا'),
                    position: NotificationPosition.bottom,
                  );
                  return;
                }
              } catch (e) {
                showSimpleNotification(
                  const Text(
                      ' تأكد من كتابتك للرقم بصورة صحيحة حيث يحتوي على ارقام فقط وليس به فاصلة'),
                  position: NotificationPosition.bottom,
                );
                return;
              }
            }
            if (isDouble) {
              try {
                if (double.parse(result).isNegative != canBeNegative) {
                  showSimpleNotification(
                    const Text('عذرا الرقم صغير جدا'),
                    position: NotificationPosition.bottom,
                  );
                  return;
                }
              } catch (e) {
                showSimpleNotification(
                  const Text(
                      'تأكد من كتابتك للرقم بصورة صحيحة حيث يحتوي على ارقام فقط'),
                  position: NotificationPosition.bottom,
                );
                return;
              }
            }
            var r = onSubmited == null ? null : (await onSubmited!(result));
            if (r == null || r) {
              nextNode?.requestFocus();
              nextController?.selection = TextSelection(
                baseOffset: 0,
                extentOffset: nextController!.text.length,
              );
            } else {
              node.requestFocus();
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            }
          },
        ),
      ),
    );
  }
}
