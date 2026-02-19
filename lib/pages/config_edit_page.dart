// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, constant_identifier_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasbeeh/providers/data.dart';

import '../util/function_util.dart';

class ConfigEditPage extends StatefulWidget {
  static const ROUTE_NAME = '/config-edit-page';

  @override
  _ConfigEditPageState createState() => _ConfigEditPageState();
}

class _ConfigEditPageState extends State<ConfigEditPage> {
  final _form = GlobalKey<FormState>();

  String? _step;
  String? _tickDuration;
  String? _minTickDuration;
  bool _isLoading = false;
  bool _isAudioActive = true;
  bool _isVibrateActive = true;
  bool _isSpeechActive = true;
  bool _isNotificationActive = true;
  bool _isUsingDevice = true;
  bool _isGradualSpeedActive = false;

  final TextEditingController _stepController = TextEditingController();
  final TextEditingController _tickDurationController = TextEditingController();
  final TextEditingController _minTickDurationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Data data = Provider.of<Data>(context, listen: false);
    _stepController.text = data.step.toString();
    _tickDurationController.text = data.tickDuration.toString();
    _minTickDurationController.text = data.minTickDuration.toString();
    _isAudioActive = data.isAudioOn;
    _isVibrateActive = data.isVibrateOn;
    _isSpeechActive = data.isSpeechOn;
    _isNotificationActive = data.isNotificationOn;
    _isUsingDevice = data.isUsingDevice;
    _isGradualSpeedActive = data.isGradualSpeedOn;
  }

  Future<void> _validateAndSubmitForm(context) async {
    if (_form.currentState?.validate() == true) {
      _form.currentState?.save();
      setState(() {
        _isLoading = true;
      });
      bool result = await Provider.of<Data>(context, listen: false)
          .saveConfigData(
              _step.toString(),
              _tickDuration.toString(),
              _minTickDuration.toString(),
              _isAudioActive.toString(),
              _isVibrateActive.toString(),
              _isSpeechActive.toString(),
              _isNotificationActive.toString(),
              _isUsingDevice.toString(),
              _isGradualSpeedActive.toString());
      if (result) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('Saved the Counts Successfully!'),
        // ));
        FunctionUtil.showSnackBar(
            context, 'Saved the Configuration Successfully!', Colors.black);
        Navigator.of(context).pop();
      } else {
        FunctionUtil.showErrorSnackBar(context);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Builder(
        builder: (context) => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          color: Colors.grey,
          child: Container(
            height: MediaQuery.of(context).size.height / 1.1,
            child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Form(
                  key: _form,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _stepController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Single Step',
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 80)),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter value for Current Count!';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) => _step = value,
                      ),
                      TextFormField(
                        controller: _tickDurationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Auto Tick Duration (Millis)',
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 80)),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter value for Auto Tick Duration!';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) => _tickDuration = value,
                      ),
                      TextFormField(
                        controller: _minTickDurationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Min Auto Tick Duration (Millis)',
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 80)),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter value for Min Auto Tick Duration!';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) => _minTickDuration = value,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 22),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Audio Alert',
                                style: TextStyle(
                                    fontSize: 16 /
                                        MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold)),
                            Transform.scale(
                                scale: 2,
                                child: Switch(
                                  onChanged: (value) {
                                    _isAudioActive = !_isAudioActive;
                                    setState(() {});
                                  },
                                  value: _isAudioActive,
                                  activeColor: Colors.green[400],
                                  activeTrackColor: Colors.blueGrey,
                                  inactiveThumbColor: Colors.blueGrey[300],
                                  inactiveTrackColor: Colors.blueGrey,
                                )),
                          ]),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 100),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Vibration Alert',
                                style: TextStyle(
                                    fontSize: 16 /
                                        MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold)),
                            Transform.scale(
                                scale: 2,
                                child: Switch(
                                  onChanged: (value) {
                                    _isVibrateActive = !_isVibrateActive;
                                    setState(() {});
                                  },
                                  value: _isVibrateActive,
                                  activeColor: Colors.green[400],
                                  activeTrackColor: Colors.blueGrey,
                                  inactiveThumbColor: Colors.blueGrey[300],
                                  inactiveTrackColor: Colors.blueGrey,
                                )),
                          ]),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 100),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Notifications',
                                style: TextStyle(
                                    fontSize: 16 /
                                        MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold)),
                            Transform.scale(
                                scale: 2,
                                child: Switch(
                                  onChanged: (value) {
                                    _isNotificationActive =
                                        !_isNotificationActive;
                                    setState(() {});
                                  },
                                  value: _isNotificationActive,
                                  activeColor: Colors.green[400],
                                  activeTrackColor: Colors.blueGrey,
                                  inactiveThumbColor: Colors.blueGrey[300],
                                  inactiveTrackColor: Colors.blueGrey,
                                )),
                          ]),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 100),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Speech Alert',
                                style: TextStyle(
                                    fontSize: 16 /
                                        MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold)),
                            Transform.scale(
                                scale: 2,
                                child: Switch(
                                  onChanged: (value) {
                                    _isSpeechActive = !_isSpeechActive;
                                    setState(() {});
                                  },
                                  value: _isSpeechActive,
                                  activeColor: Colors.green[400],
                                  activeTrackColor: Colors.blueGrey,
                                  inactiveThumbColor: Colors.blueGrey[300],
                                  inactiveTrackColor: Colors.blueGrey,
                                )),
                          ]),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 100),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Auto Tasbeeh Speed',
                                style: TextStyle(
                                    fontSize: 16 /
                                        MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold)),
                            Transform.scale(
                                scale: 2,
                                child: Switch(
                                  onChanged: (value) {
                                    _isGradualSpeedActive =
                                        !_isGradualSpeedActive;
                                    setState(() {});
                                  },
                                  value: _isGradualSpeedActive,
                                  activeColor: Colors.green[400],
                                  activeTrackColor: Colors.blueGrey,
                                  inactiveThumbColor: Colors.blueGrey[300],
                                  inactiveTrackColor: Colors.blueGrey,
                                )),
                          ]),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 100),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Use Smart Device',
                                style: TextStyle(
                                    fontSize: 16 /
                                        MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold)),
                            Transform.scale(
                                scale: 2,
                                child: Switch(
                                  onChanged: (value) {
                                    _isUsingDevice = !_isUsingDevice;
                                    setState(() {});
                                  },
                                  value: _isUsingDevice,
                                  activeColor: Colors.green[400],
                                  activeTrackColor: Colors.blueGrey,
                                  inactiveThumbColor: Colors.blueGrey[300],
                                  inactiveTrackColor: Colors.blueGrey,
                                )),
                          ]),
                      SizedBox(height: MediaQuery.of(context).size.height / 15),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                elevation: 4,
                              ),
                              child: const Text('        Save        ',
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () => _validateAndSubmitForm(context),
                            ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
