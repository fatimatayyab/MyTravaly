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
    // 1. Use 'propertyAddress' key from the JSON, not 'address'
    final address = json['propertyAddress'] ?? {};

    // 2. Safely access Google Review data for the rating
    final googleReviewData = json['googleReview']?['data'] ?? {};

    // 3. Determine image URL safely
    String imgUrl = '';
    final propertyImage = json['propertyImage'];

    if (propertyImage is String && propertyImage.isNotEmpty) {
      imgUrl = propertyImage;
    } else if (propertyImage is Map && propertyImage['fullUrl'] != null) {
      imgUrl = propertyImage['fullUrl'];
    }

    // Determine the rating: prefer Google Review rating, otherwise use propertyStar
    final ratingValue =
        googleReviewData['overallRating'] ?? json['propertyStar'] ?? 0;

    return Hotel(
      // 4. Use 'propertyCode' for the ID as 'searchArray' is missing in the JSON
      id: json['propertyCode'] ?? '',
      name: json['propertyName'] ?? 'Unknown',
      // City, State, Country are correctly pulled from the 'propertyAddress' map
      city: address['city'] ?? '',
      state: address['state'] ?? '',
      country: address['country'] ?? '',
      // Use the derived rating value (Google Review or propertyStar)
      rating: (ratingValue).toDouble(),
      // 5. Use 'staticPrice' key for the price, not 'propertyMinPrice'
      pricePerNight: (json['staticPrice']?['amount'] ?? 0).toDouble(),
      imageUrl: imgUrl.isNotEmpty ? imgUrl : 'assets/images/hotel.png',
      description: json['description'] ?? 'No description available.',
    );
  }
}
