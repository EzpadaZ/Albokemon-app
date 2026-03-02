import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class Device {
  static late AndroidDeviceInfo _androidDeviceInfo;
  static late IosDeviceInfo _iosDeviceInfo;
  static late DeviceInfoPlugin _deviceInfoPlugin;

  static init() async {
    _deviceInfoPlugin = DeviceInfoPlugin();
    await _detectDevice();
  }

  static _detectDevice() async {
    if (Platform.isIOS) {
      _iosDeviceInfo = await _deviceInfoPlugin.iosInfo;
    } else {
      _androidDeviceInfo = await _deviceInfoPlugin.androidInfo;
    }
  }

  static getOSName() {
    // returns platform release name
    return (Platform.isIOS)
        ? _iosDeviceInfo.systemName
        : _androidDeviceInfo.version.codename;
  }

  static getOSVersion() {
    // returns platform release version
    return (Platform.isIOS)
        ? _iosDeviceInfo.systemVersion
        : _androidDeviceInfo.version.release;
  }

  static getPlatformName() {
    // returns platform
    return Platform.isIOS ? "iOS" : "Android";
  }

  static isPhysicalDevice() {
    //returns true if physical device, false if running on simulator.
    if (Platform.isIOS) {
      return (_iosDeviceInfo.isPhysicalDevice);
    } else {
      return (_androidDeviceInfo.isPhysicalDevice);
    }
  }

  static getDeviceBrandModel() {
    if (Platform.isIOS) {
      return _iosDeviceInfo.model.toLowerCase();
    } else {
      return ('${_androidDeviceInfo.brand} - ${_androidDeviceInfo.model}')
          .toLowerCase();
    }
  }

  static Map<String, dynamic> getDeviceMetadata() {
    return {
      "isPhysicalDevice": isPhysicalDevice(),
      "osName": getOSName(),
      "brand": getDeviceBrandModel(),
      "osVersion": getOSVersion(),
      "platform": getPlatformName(),
    };
  }
}
