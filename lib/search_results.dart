import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mytravely_app/model/hotel.dart';
import 'package:mytravely_app/services/apiservice.dart';
import 'package:mytravely_app/widgets/hotel_card.dart';

class SearchResultsPage extends StatefulWidget {
  final TextEditingController queryController;

  const SearchResultsPage({super.key, required this.queryController});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final HotelService _hotelService = HotelService();
  final List<Hotel> _hotels = [];
  bool _loading = false;
  Timer? _debounce;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchHotels(widget.queryController.text);

    // Listen to typing with debounce
    widget.queryController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchHotels(widget.queryController.text);
    });
  }

  Future<void> _fetchHotels(String query, {bool loadMore = false}) async {
    if (query.isEmpty) {
      setState(() {
        _hotels.clear();
        _currentPage = 1;
        _hasMore = true;
        _errorMessage = null;
      });
      return;
    }

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _hotels.clear();
    }

    if (!_hasMore) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final results = await _hotelService.fetchHotels(
        query,
        page: _currentPage,
      );

      setState(() {
        _hotels.addAll(results);
        _hasMore = results.length == 10; // page size = 10
        _currentPage++;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to fetch hotels. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    widget.queryController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: _buildSearchBar(),
        backgroundColor: const Color.fromARGB(255, 250, 74, 132),
      ),
      body: _loading && _hotels.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _hotels.isEmpty
          ? _buildEmptyView()
          : _buildHotelList(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: widget.queryController,
      decoration: const InputDecoration(
        hintText: 'Search by hotel, city, state, or country',
        border: InputBorder.none,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildHotelList() {
    return RefreshIndicator(
      onRefresh: () => _fetchHotels(widget.queryController.text),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent &&
              !_loading &&
              _hasMore) {
            _fetchHotels(widget.queryController.text, loadMore: true);
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _hotels.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _hotels.length) {
              return HotelCard(hotel: _hotels[index]);
            } else {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        'No results found',
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
