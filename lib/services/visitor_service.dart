import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mytravely_app/config/app_config.dart';
import 'device_service.dart';

//baseUrl and AuthToken in Config File. 
//Not Committed For Security

class VisitorService {
  static String? visitorToken;
  Future<String?> registerDevice() async {
    final deviceDetails = await DeviceService.getDeviceDetails();

    final body = jsonEncode({
      "action": "deviceRegister",
      "deviceRegister": deviceDetails,
    });
    try {
      final response = await http.post(
        Uri.parse(AppConfig.baseUrl),
        headers: {
          "Content-Type": "application/json",
          "authtoken": AppConfig.authToken,
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        visitorToken =
            data['visitorToken'] ?? data['data']?['visitorToken']; // ✅ store
        return visitorToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
