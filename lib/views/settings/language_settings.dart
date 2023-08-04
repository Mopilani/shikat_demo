import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSettings extends StatefulWidget {
  const LanguageSettings({
    Key? key,
  }) : super(key: key);

  @override
  State<LanguageSettings> createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'language_settings',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ).tr(),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 26),
            margin: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: const Text(
              'choose_language',
              style: TextStyle(
                color: Colors.blue,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ).tr(),
          ),
          _SwitchListTileMenuItem(
              title: 'عربي',
              subtitle: 'عربي',
              locale:
                  context.supportedLocales[1] //BuildContext extension method
              ),
          const _Divider(),
          _SwitchListTileMenuItem(
              title: 'English',
              subtitle: 'English',
              locale: context.supportedLocales[0]),
          const _Divider(),
        ],
      ),
    );
  }
}

class _SwitchListTileMenuItem extends StatelessWidget {
  const _SwitchListTileMenuItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.locale,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Locale locale;

  bool isSelected(BuildContext context) => locale == context.locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(
        border:
            isSelected(context) ? Border.all(color: Colors.blueAccent) : null,
      ),
      child: ListTile(
        dense: true,
        // isThreeLine: true,
        title: Text(
          title,
        ),
        subtitle: Text(
          subtitle,
        ),
        onTap: () async {
          log(locale.toString(), name: toString());
          await context.setLocale(locale); //BuildContext extension method
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: const Divider(
        color: Colors.grey,
      ),
    );
  }
}



// class LanguageSetting extends StatefulWidget {
//   const LanguageSetting({Key? key}) : super(key: key);

//   @override
//   _LanguageSettingsState createState() => _LanguageSettingsState();
// }

// class _LanguageSettingsState extends State<LanguageSettings> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           LanguageSettingsAppBar(),
//         ],
//       ),
//     );
//   }
// }

// class LanguageSettingsAppBar extends StatelessWidget {
//   const LanguageSettingsAppBar({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
//       child: AppBar(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         title: const Text('Language Settings'),
//         centerTitle: true,
//         actions: [],
//       ),
//     );
//   }
// }
