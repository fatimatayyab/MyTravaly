import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mytravely_app/model/hotel.dart';

class HotelService {
  final String baseUrl = "https://api.mytravaly.com/public/v1/";
  final String authToken = "71523fdd8d26f585315b4233e39d9263";
  final String visitorToken = "5528-e438-a79f-67bc-b81f-c672-5afb-7148";

  static const int pageSize = 5;

  Future<List<Hotel>> fetchHotels(String query, {int page = 1}) async {
    final q = query.trim();

    if (q.isEmpty) {
      return [];
    }

    try {
      final offset = (page - 1) * pageSize;
      final ids = await _fetchHotelIds(q, pageSize, offset);

      if (ids.isEmpty) {
        return [];
      }

      final hotels = await _fetchHotelsByIds(ids);
      return hotels;
    } catch (e, st) {
      return [];
    }
  }

  Future<List<String>> _fetchHotelIds(
    String query,
    int limit,
    int offset,
  ) async {
    final body = jsonEncode({
      "action": "searchAutoComplete",
      "searchAutoComplete": {
        "inputText": query,
        "searchType": [
          "byPropertyName",
          "byCity",
          "byState",
          "byCountry",
          "byRandom",
        ],
        "limit": limit,
        "offset": offset,
      },
    });

    try {
      final resp = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              "Content-Type": "application/json",
              "authtoken": authToken,
              "visitortoken": visitorToken,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(resp.body);
      if (data == null || data['status'] != true) {
        return [];
      }

      final auto = data['data']?['autoCompleteList'];
      if (auto == null) {
        return [];
      }

      final Set<String> ids = {};

      void tryAddId(dynamic v) {
        if (v == null) return;
        final s = v.toString();
        if (s.isNotEmpty &&
            s.length > 3 &&
            RegExp(r'^[a-zA-Z0-9]+$').hasMatch(s)) {
          ids.add(s);
        }
      }

      final byProp = auto['byPropertyName'];
      if (byProp != null && byProp['present'] == true) {
        final list = byProp['listOfResult'] as List? ?? [];
        for (final item in list) {
          if (item == null) continue;
          if (item['propertyCode'] != null) {
            tryAddId(item['propertyCode']);
            continue;
          }
          final sa = item['searchArray'];
          if (sa != null && sa['query'] is List && sa['query'].isNotEmpty) {
            tryAddId(sa['query'][0]);
          }
        }
      }

      final otherTypes = ['byCity', 'byState', 'byCountry', 'byRandom'];
      for (final t in otherTypes) {
        final block = auto[t];
        if (block != null && block['present'] == true) {
          final list = block['listOfResult'] as List? ?? [];
          for (final item in list) {
            if (item == null) continue;
            if (item['propertyCode'] != null) {
              tryAddId(item['propertyCode']);
            }
            final sa = item['searchArray'];
            if (sa != null && sa['query'] is List) {
              for (final q in sa['query']) {
                tryAddId(q);
              }
            }
          }
        }
      }

      final extracted = ids.toList();

      final limited = extracted.take(limit).toList();
      return limited;
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Hotel>> _fetchHotelsByIds(List<String> hotelIds) async {
    List<Hotel> allHotels = [];

    for (final id in hotelIds) {
      final body = jsonEncode({
        "action": "getSearchResultListOfHotels",
        "getSearchResultListOfHotels": {
          "searchCriteria": {
            "checkIn": "2026-07-11",
            "checkOut": "2026-07-12",
            "rooms": 1,
            "adults": 1,
            "children": 0,
            "searchType": "hotelIdSearch",
            "searchQuery": [id],
            "accommodation": ["all"],
            "currency": "INR",
            "limit": 5,
            "rid": 0,
          },
        },
      });

      try {
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'authtoken': authToken,
            'visitortoken': visitorToken,
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final data = jsonResponse['data'];

          if (data != null) {
            final hotelsList = data['arrayOfHotelList'] ?? [];

            for (var hotelData in hotelsList) {
              try {
                if (allHotels.length >= HotelService.pageSize) break;
                allHotels.add(Hotel.fromJson(hotelData));
              } catch (e) {
                //catch
              }
            }
          } else {}
        } else {}
      } catch (e) {
                        //catch

      }
    }

    return allHotels;
  }
}
