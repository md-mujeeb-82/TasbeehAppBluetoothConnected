// ignore_for_file: prefer_interpolation_to_compose_strings, annotate_overrides, avoid_print, constant_identifier_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasbeeh/services/audio_handler.dart';
import 'package:tasbeeh/util/audio_util.dart';
import 'package:tasbeeh/util/notifications_util.dart';
import 'package:vibration/vibration.dart';

class Data with ChangeNotifier {
  static const SHARED_PREFERENCES_KEY = 'TasbeehData';
  static const KEY_COUNT = 'count';
  static const KEY_TARGET_COUNT = 'targetCount';
  static const KEY_DAY_COUNT = 'dayCount';
  static const KEY_TOTAL_COUNT = 'totalCount';
  static const KEY_STEP = 'step';
  static const KEY_TICK_DURATION = 'tickDuration';
  static const KEY_MIN_TICK_DURATION = 'minTickDuration';
  static const KEY_AUDIO_ON = 'isAudioOn';
  static const KEY_VIBRATE_ON = 'isVibrateOn';
  static const KEY_IS_SPEECH_ON = 'isSpeechOn';
  static const KEY_IS_NOTIFICATION_ON = 'isNotificationOn';
  static const KEY_IS_USING_DEVICE = 'isUsingDevice';
  static const KEY_GRADUAL_SPEED_ON = 'isGradualSpeedOn';
  static const KEY_IS_PLAY_PAUSE = 'isPlayPause';

  final dynamic _data = {};
  AudioUtil audioUtil = AudioUtil();
  NotificationsUtil notificationUtil = NotificationsUtil();
  TasbeehAudioHandler? _audioHandler;
  BluetoothDevice? tasbeehDevice;
  BluetoothConnection? connection;
  bool isDeviceOffline = false;

  Data() {
    _data['count'] = 0;
    _data['targetCount'] = 100;
    _data['dayCount'] = 0;
    _data['totalCount'] = 0;
    _data['step'] = 1;
    _data['tickDuration'] = 2000;
    _data['minTickDuration'] = 1150;
    _data['isAudioOn'] = true;
    _data['isVibrateOn'] = true;
    _data['isSpeechOn'] = true;
    _data['isNotificationOn'] = false;
    _data['isUsingDevice'] = false;
    _data['isGradualSpeedOn'] = false;
    _data['isPlayPause'] = false;
    setDirty(true);

    // For Audio Service
    audioUtil.loadAudio();
  }

  Future<bool> fetchAndSetData() async {
    dynamic prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      dynamic data = prefs.get(SHARED_PREFERENCES_KEY);
      if (data == null) {
        return true;
      }

      _audioHandler = (await initAudioService() as TasbeehAudioHandler);
      _audioHandler?.setData(this);

      data = json.decode(data);
      _data['count'] = int.parse(data[KEY_COUNT]);
      _data['targetCount'] = int.parse(data[KEY_TARGET_COUNT]);
      _data['dayCount'] = int.parse(data[KEY_DAY_COUNT]);
      _data['totalCount'] = int.parse(data[KEY_TOTAL_COUNT]);
      _data['step'] = int.parse(data[KEY_STEP]);
      _data['tickDuration'] = int.parse(data[KEY_TICK_DURATION]);
      _data['minTickDuration'] = int.parse(data[KEY_MIN_TICK_DURATION]);
      _data['isAudioOn'] =
          data[KEY_AUDIO_ON].toString().toLowerCase() == 'true';
      _data['isVibrateOn'] =
          data[KEY_VIBRATE_ON].toString().toLowerCase() == 'true';
      _data['isSpeechOn'] =
          data[KEY_IS_SPEECH_ON].toString().toLowerCase() == 'true';
      _data['isNotificationOn'] =
          data[KEY_IS_NOTIFICATION_ON].toString().toLowerCase() == 'true';
      _data['isUsingDevice'] =
          data[KEY_IS_USING_DEVICE].toString().toLowerCase() == 'true';
      _data['isGradualSpeedOn'] =
          data[KEY_GRADUAL_SPEED_ON].toString().toLowerCase() == 'true';
      _data['isPlayPause'] =
          data[KEY_IS_PLAY_PAUSE].toString().toLowerCase() == 'true';
      setDirty(true);
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  void setBluetoothDevice(BluetoothDevice device) async {
    tasbeehDevice = device;
    if (tasbeehDevice != null) {
      connectBluetoothDeviceAndListen();
    }
  }

  Future<bool> saveData() async {
    dynamic prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          SHARED_PREFERENCES_KEY,
          json.encode({
            KEY_COUNT: count.toString(),
            KEY_TARGET_COUNT: targetCount.toString(),
            KEY_DAY_COUNT: dayCount.toString(),
            KEY_TOTAL_COUNT: totalCount.toString(),
            KEY_STEP: step.toString(),
            KEY_TICK_DURATION: tickDuration.toString(),
            KEY_MIN_TICK_DURATION: minTickDuration.toString(),
            KEY_AUDIO_ON: isAudioOn.toString(),
            KEY_VIBRATE_ON: isVibrateOn.toString(),
            KEY_IS_SPEECH_ON: isSpeechOn.toString(),
            KEY_IS_NOTIFICATION_ON: isNotificationOn.toString(),
            KEY_IS_USING_DEVICE: isUsingDevice.toString(),
            KEY_GRADUAL_SPEED_ON: isGradualSpeedOn.toString(),
            KEY_IS_PLAY_PAUSE: isPlayPause.toString()
          }));
      setDirty(true);
      notifyListeners();

      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> saveCounts(String pCount, String pTargetCount, String pDayCount,
      String pTotalCount) async {
    _data['count'] = int.parse(pCount);
    _data['targetCount'] = int.parse(pTargetCount);
    _data['dayCount'] = int.parse(pDayCount);
    _data['totalCount'] = int.parse(pTotalCount);

    return await saveData();
  }

  Future<bool> saveConfigData(
      String pStep,
      String pTickDuration,
      String pMinTickDuration,
      String pIsAudioOn,
      String pIsVibrateOn,
      String pIsSpeechOn,
      String pIsNotificationOn,
      String pIsUsingDevice,
      String pIsGradualSpeedOn) async {
    _data['step'] = int.parse(pStep);
    _data['tickDuration'] = int.parse(pTickDuration);
    _data['minTickDuration'] = int.parse(pMinTickDuration);
    _data['isAudioOn'] = pIsAudioOn.toLowerCase() == 'true';
    _data['isVibrateOn'] = pIsVibrateOn.toLowerCase() == 'true';
    _data['isSpeechOn'] = pIsSpeechOn.toLowerCase() == 'true';
    _data['isNotificationOn'] = pIsNotificationOn.toLowerCase() == 'true';
    _data['isUsingDevice'] = pIsUsingDevice.toLowerCase() == 'true';
    _data['isGradualSpeedOn'] = pIsGradualSpeedOn.toLowerCase() == 'true';

    return await saveData();
  }

  Future<bool> changePlayPauseState(bool state) async {
    _data['isPlayPause'] = state;

    if (isPlayPause) {
      if (tasbeehDevice != null &&
          !isDeviceOffline &&
          (connection == null || !connection!.isConnected)) {
        connectBluetoothDeviceAndListen();
      }
    }

    return await saveData();
  }

  Future<void> togglePlayPause() async {
    audioHandler!.handleButtonClick(!isPlayPause);
  }

  Future<bool> endSession() async {
    _data['dayCount'] = dayCount + count;
    _data['count'] = 0;

    return await saveData();
  }

  Future<bool> endDay() async {
    _data['dayCount'] = dayCount + count;
    _data['totalCount'] = totalCount + dayCount;
    _data['count'] = 0;
    _data['dayCount'] = 0;

    return await saveData();
  }

  Future<bool> resetCurrentCount() async {
    _data['count'] = 0;

    return await saveData();
  }

  Future<void> incrementTasbeeh() async {
    _data['count'] = count + step;
    await saveData();

    // If using device, send notifications on Device; otherwise on Phone
    if (!isDeviceOffline && isUsingDevice && tasbeehDevice != null) {
      if (tasbeehDevice != null &&
          !isDeviceOffline &&
          (connection == null || !connection!.isConnected)) {
        connectBluetoothDeviceAndListen();
      }

      if (count != 0 && count == targetCount) {
        connection!.output.add(Uint8List.fromList(
            ('2' + (isAudioOn ? '1' : '0') + (isVibrateOn ? '1' : '0'))
                .codeUnits));
      } else if (count % 100 == 0) {
        connection!.output.add(Uint8List.fromList(
            ('1' + (isAudioOn ? '1' : '0') + (isVibrateOn ? '1' : '0'))
                .codeUnits));
      } else {
        connection!.output.add(Uint8List.fromList(
            ('0' + (isAudioOn ? '1' : '0') + (isVibrateOn ? '1' : '0'))
                .codeUnits));
      }
    } else {
      if (isAudioOn) {
        if (count != 0 && count == targetCount) {
          await audioUtil.playTasbeehCompleteAudio(isSpeechOn);
        } else if (count % 100 == 0) {
          await audioUtil.play100CompleteAudio(
              isSpeechOn, isGradualSpeedOn && count > 30);
        } else {
          await audioUtil.playTickAudio(
              isSpeechOn, isGradualSpeedOn && count > 30);
        }
      }

      if (isVibrateOn) {
        // In order to aoid phone going to Sleep mode.
        if (!isAudioOn) {
          audioUtil.playSilenceAudio();
        }

        if (count != 0 && count == targetCount) {
          await vibrate(1000, 1);
        } else if (count % 100 == 0) {
          await vibrate(100, 3);
        } else {
          await vibrate(100, 1);
        }
      }

      if (isNotificationOn) {
        // if (count != 0 && count == targetCount) {
        //   await notificationUtil.showNotification(5, this);
        // } else if (count % 100 == 0) {
        //   await notificationUtil.showNotification(2, this);
        // } else {
        //   await notificationUtil.showNotification(1, this);
        // }
        await notificationUtil.showNotification(1, this);
      }
    }
  }

  Future<void> vibrate(int millis, int count) async {
    for (int i = 0; i < count; i++) {
      Vibration.vibrate(duration: millis);
    }
  }

  void connectBluetoothDeviceAndListen() async {
    if (isDeviceConnected) {
      return;
    }
    try {
      connection = await BluetoothConnection.toAddress(tasbeehDevice!.address);
      isDeviceOffline = false;
      setDirty(true);

      connection!.input!.listen((Uint8List data) async {
        await togglePlayPause();
      });
    } catch (error) {
      isDeviceOffline = true;
    }
  }

  void disconnectDevice() async {
    try {
      await connection!.finish();
      isDeviceOffline = false;
      setDirty(true);
    } catch (error) {
      isDeviceOffline = true;
    }
  }

  void setDirty(bool state) {
    _data['isDirty'] = state;
  }

  dynamic get data {
    return _data;
  }

  int get count {
    return _data['count'];
  }

  int get targetCount {
    return _data['targetCount'];
  }

  int get dayCount {
    return _data['dayCount'];
  }

  int get totalCount {
    return _data['totalCount'];
  }

  int get step {
    return _data['step'];
  }

  int get tickDuration {
    return _data['tickDuration'];
  }

  int get minTickDuration {
    return _data['minTickDuration'];
  }

  bool get isAudioOn {
    return _data['isAudioOn'];
  }

  bool get isVibrateOn {
    return _data['isVibrateOn'];
  }

  bool get isNotificationOn {
    return _data['isNotificationOn'];
  }

  bool get isUsingDevice {
    return _data['isUsingDevice'];
  }

  bool get isSpeechOn {
    return _data['isSpeechOn'];
  }

  bool get isGradualSpeedOn {
    return _data['isGradualSpeedOn'];
  }

  bool get isPlayPause {
    return _data['isPlayPause'];
  }

  TasbeehAudioHandler? get audioHandler {
    return _audioHandler;
  }

  bool get isDeviceConnected {
    if (connection != null && connection!.isConnected) {
      return true;
    } else {
      return false;
    }
  }

  bool get isDirty {
    return _data['isDirty'];
  }
}
