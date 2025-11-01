import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:mytravely_app/model/hotel.dart';


class HotelService {
  final String baseUrl = "https://api.mytravaly.com/public/v1/";
  final String authToken = "71523fdd8d26f585315b4233e39d9263";
  final String visitorToken = "5528-e438-a79f-67bc-b81f-c672-5afb-7148";

Future<List<Hotel>> fetchHotels(String query, {int page = 1}) async {
  final int limit = 10;
  final int offset = (page - 1) * limit;

  final body = jsonEncode({
    "action": "searchAutoComplete",
    "searchAutoComplete": {
      "inputText": query,
      "searchType": ["byCity", "byState", "byCountry", "byPropertyName"],
      "limit": limit,
      "offset": offset, 
    },
  });

  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {
      "Content-Type": "application/json",
      "authtoken": authToken,
      "visitortoken": visitorToken,
    },
    body: body,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['status'] == true &&
        data['data'] != null &&
        data['data']['autoCompleteList'] != null) {
      final autoCompleteList = data['data']['autoCompleteList'];
      final results = [];

      autoCompleteList.forEach((key, value) {
        if (value['present'] == true && value['listOfResult'] != null) {
          results.addAll(value['listOfResult']);
        }
      });

      return results.map((json) => Hotel.fromJson(json)).toList();
    } else {
      return [];
    }
  } else {
    throw Exception('Failed to load hotels: ${response.statusCode}');
  }
}
}