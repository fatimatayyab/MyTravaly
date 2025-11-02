import 'package:flutter/material.dart';
import 'package:mytravely_app/model/hotel.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;

  const HotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Hotel Image
            _buildHotelImage(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameAndStarRating(),
                  const SizedBox(height: 4),
                  Text(
                    [
                      hotel.city,
                      hotel.state,
                      hotel.country,
                    ].where((s) => s.isNotEmpty).join(', '),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildGuestRating(),
                  const SizedBox(height: 6),
                  Text(
                    "${hotel.displayPrice} per night",
                    style: const TextStyle(
                      color: Colors.deepOrange, // Changed color for emphasis
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (hotel.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      hotel.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage() {
    final bool isNetworkImage =
        hotel.imageUrl.isNotEmpty && hotel.imageUrl.startsWith('http');
    const double imageSize = 100;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isNetworkImage
          ? Image.network(
              hotel.imageUrl,
              height: imageSize,
              width: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(imageSize),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildPlaceholderImage(imageSize, loading: true);
              },
            )
          : Image.asset(
              'assets/images/hotel.png',
              height: imageSize,
              width: imageSize,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildNameAndStarRating() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            hotel.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hotel.starRating > 0)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                hotel.starRating.clamp(1, 5),
                (index) =>
                    const Icon(Icons.star, color: Colors.amber, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGuestRating() {
    if (hotel.rating > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hotel.rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.thumb_up, color: Colors.white, size: 12),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPlaceholderImage(double size, {bool loading = false}) {
    return Container(
      height: size,
      width: size,
      color: Colors.grey.shade300,
      child: Center(
        child: loading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : const Icon(Icons.broken_image, color: Colors.grey, size: 30),
      ),
    );
  }
}
