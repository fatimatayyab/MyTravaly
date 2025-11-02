class Hotel {
  final String id;
  final String name;
  final String city;
  final String state;
  final String country;
  final double rating;
  final String displayPrice;
  final String imageUrl;
  final String description;
  final int starRating;

  Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.rating,
    required this.displayPrice,
    required this.imageUrl,
    required this.description,
    required this.starRating,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final String id =
        (json['searchArray']?['query'] != null &&
            json['searchArray']['query'].isNotEmpty)
        ? json['searchArray']['query'][0].toString()
        : (json['propertyCode'] as String?) ?? '';

    final address = json['address'] ?? json['propertyAddress'] ?? {};

    final priceMap = json['staticPrice'] ?? json['markedPrice'];
    final String price = priceMap?['displayAmount'] as String? ?? 'Price N/A';

    final double overallRating =
        json['googleReview']?['data']?['overallRating'] as double? ?? 0.0;

    String imgUrl = '';
    final propertyImage = json['propertyImage'];

    if (propertyImage is String && propertyImage.isNotEmpty) {
      imgUrl = propertyImage.trim();
    } else if (propertyImage is Map<String, dynamic> &&
        propertyImage['fullUrl'] is String &&
        (propertyImage['fullUrl'] as String).isNotEmpty) {
      imgUrl = (propertyImage['fullUrl'] as String).trim();
    }

    return Hotel(
      id: id,
      name: json['propertyName'] ?? json['valueToDisplay'] ?? 'Unknown',
      city: address['city'] ?? '',
      state: address['state'] ?? '',
      country: address['country'] ?? '',
      rating: overallRating,
      displayPrice: price,
      imageUrl: imgUrl.isNotEmpty ? imgUrl : 'assets/images/hotel.png',
      description: json['description'] ?? 'No description available.',
      starRating: json['propertyStar'] as int? ?? 0,
    );
  }
}
