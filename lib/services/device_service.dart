class DeviceService {

  static Future<Map<String, String>> getDeviceDetails() async {
    // 🔹 Hardcoded device info for demostration purpose
    // Later It can be achieved from some package extracting current device's info.
    return {
      "deviceModel": "RMX3521",
      "deviceFingerprint":
          "realme/RMX3521/RE54E2L1:13/RKQ1.211119.001/S.f1bb32-7f7fa_1:user/release-keys",
      "deviceBrand": "realme",
      "deviceId": "RE54E2L1",
      "deviceName": "RMX3521_11_C.10",
      "deviceManufacturer": "realme",
      "deviceProduct": "RMX3521",
      "deviceSerialNumber": "unknown",
    };
  }
}
