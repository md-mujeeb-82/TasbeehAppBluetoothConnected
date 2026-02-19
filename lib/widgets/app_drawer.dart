// ignore_for_file: use_key_in_widget_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tasbeeh/pages/config_edit_page.dart';
import 'package:tasbeeh/pages/counts_edit_page.dart';

import '../pages/about_page.dart';
import '../widgets/custom_alert_dialog.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          height: 130,
          padding: const EdgeInsets.all(8),
          child: SafeArea(
            child: Text(
              'Smart Tasbeeh',
              style: TextStyle(
                fontSize: Platform.isAndroid ? 20 : 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit Tasbeeh Counts'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(CountsEditPage.ROUTE_NAME);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configuration'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(ConfigEditPage.ROUTE_NAME);
          },
        ),
        const Divider(),
        ListTile(
          leading:
              const Hero(tag: 'about-water', child: Icon(Icons.celebration)),
          title: const Text('About Tasbeeh'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(AboutPage.ROUTE_NAME);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Exit'),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => CustomAlertDialog(
                'Confirm Operation',
                'Are you sure you want to Exit from the App?',
              ),
            ).then((result) async {
              if (result) {
                exit(0);
              }
            });
          },
        ),
        const Divider(),
      ],
    );
  }
}
