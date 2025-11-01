import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mytravely_app/data/sample_hotels.dart';
import 'package:mytravely_app/model/hotel.dart';
import 'package:mytravely_app/services/apiservice.dart';
import 'package:mytravely_app/widgets/hotel_card.dart';
import 'package:mytravely_app/search_results.dart';

class HotelListPage extends StatefulWidget {
  const HotelListPage({super.key});

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  final HotelService _hotelService = HotelService();
  final TextEditingController _searchController = TextEditingController();

  List<Hotel> _hotels = [];
  bool _loading = false;
  Timer? _debounce;
  bool _navigatedToResults = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _hotels = sampleHotels;

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _hotels = sampleHotels;
        _errorMessage = null;
        _navigatedToResults = false;
      });
      return;
    }

    // Navigate to SearchResultsPage once
    if (!_navigatedToResults) {
      _navigatedToResults = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SearchResultsPage(queryController: _searchController),
        ),
      ).then((_) => _navigatedToResults = false);
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final results = await _hotelService.fetchHotels(query);
      setState(() => _hotels = results);
    } catch (e) {
      setState(() {
        _hotels = [];
        _errorMessage = 'Failed to fetch hotels. Try again.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Hotels'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 250, 74, 132),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildSearchBar(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _hotels.isEmpty
                  ? _buildEmptyView()
                  : _buildHotelList(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by hotel, city, state, or country',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelList() {
    return RefreshIndicator(
      onRefresh: () => _performSearch(_searchController.text.trim()),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _hotels.length,
        itemBuilder: (context, index) => HotelCard(hotel: _hotels[index]),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        'No hotels found',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Text(
        _errorMessage!,
        style: const TextStyle(fontSize: 16, color: Colors.red),
      ),
    );
  }
}
