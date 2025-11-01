import 'package:mytravely_app/model/hotel.dart';

final List<Hotel> sampleHotels = [
  Hotel(
    id: 'h1',
    name: "Regenta Inn, Indiranagar",
    city: "Bangalore",
    state: "Karnataka",
    country: "India",
    rating: 4.3,
    pricePerNight: 2500,
    imageUrl:
        "https://dwq3yv87q1b43.cloudfront.net/public/property/property_images/fit-in/600x600/1171844694-1401210705.jpg",
    description:
        "Modern hotel located in the heart of Indiranagar, close to shopping and dining areas.",
  ),
  Hotel(
    id: 'h2',
    name: "Hotel India International Dx",
    city: "New Delhi",
    state: "Delhi",
    country: "India",
    rating: 3.8,
    pricePerNight: 1800,
    imageUrl:
        "https://dwq3yv87q1b43.cloudfront.net/public/property/property_images/fit-in/600x600/725350030-2072256155.jpg",
    description:
        "A budget-friendly hotel near New Delhi Railway Station with comfortable rooms.",
  ),
  Hotel(
    id: 'h3',
    name: "Super Hotel O Indiranagar Bangalore",
    city: "Bengaluru",
    state: "Karnataka",
    country: "India",
    rating: 4.1,
    pricePerNight: 3200,
    imageUrl:
        "https://dwq3yv87q1b43.cloudfront.net/public/property/property_images/fit-in/600x600/1601635711-1441904012.jpg",
    description:
        "Stylish boutique stay in Indiranagar offering free WiFi and complimentary breakfast.",
  ),
  Hotel(
    id: 'h4',
    name: "Hotel Holideiinn",
    city: "Jamshedpur",
    state: "Jharkhand",
    country: "India",
    rating: 4.5,
    pricePerNight: 2100,
    imageUrl:
        "https://dwq3yv87q1b43.cloudfront.net/public/property/property_images/fit-in/600x600/725350030-2072256155.jpg",
    description:
        "A comfortable stay in Jamshedpur with modern amenities and easy access to local attractions.",
  ),
];

// Optional: API-like structure for testing search results
final List<Map<String, dynamic>> sampleHotelsApiFormat = sampleHotels.map((hotel) {
  return {
    'propertyId': hotel.id,
    'propertyName': hotel.name,
    'address': {
      'city': hotel.city,
      'state': hotel.state,
      'country': hotel.country,
    },
    'propertyStar': hotel.rating,
    'propertyMinPrice': {'amount': hotel.pricePerNight},
    'propertyImage': {'fullUrl': hotel.imageUrl},
    'description': hotel.description,
    'searchArray': {
      'query': [hotel.id]
    }
  };
}).toList();
