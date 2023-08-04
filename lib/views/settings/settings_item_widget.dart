import '/models/navigator_model.dart';
import 'package:flutter/material.dart';

import '../../models/settings_item_model.dart';

class SettingsItemWidget extends StatelessWidget {
  const SettingsItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);
  final SettingsItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => item.route,
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Icon(
                  item.icon,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
              SizedBox(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsItemWidgetX extends StatelessWidget {
  const SettingsItemWidgetX({
    Key? key,
    required this.item,
  }) : super(key: key);
  final SettingsItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SysNav.push(
          context,
          item.route,
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Icon(
                  item.icon,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
              SizedBox(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
