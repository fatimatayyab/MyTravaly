class Hotel {
  final String id;
  final String name;
  final String city;
  final String state;
  final String country;
  final double rating;
  final double pricePerNight;
  final String imageUrl;
  final String description;

  Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.rating,
    required this.pricePerNight,
    required this.imageUrl,
    required this.description,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};
    final searchArray = json['searchArray'] ?? {};

    return Hotel(
      id: (searchArray['query'] != null && searchArray['query'].isNotEmpty)
          ? searchArray['query'][0].toString()
          : '',
      name: json['propertyName'] ?? json['valueToDisplay'] ?? 'Unknown',
      city: address['city'] ?? '',
      state: address['state'] ?? '',
      country: address['country'] ?? '',
      rating: (json['propertyStar'] ?? 0).toDouble(),
      pricePerNight: (json['propertyMinPrice']?['amount'] ?? 0).toDouble(),
      imageUrl: json['propertyImage'] ?? 'assets/images/hotel.png',
      description: json['description'] ?? 'No description available.',
    );
  }
}
