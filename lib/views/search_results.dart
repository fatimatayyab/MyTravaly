import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mytravely_app/model/hotel.dart';
import 'package:mytravely_app/services/hotel_service.dart';
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
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    widget.queryController.addListener(_onSearchChanged);

    final initialQuery = widget.queryController.text.trim();
    if (initialQuery.isNotEmpty) {
      _fetchHotels(initialQuery, reset: true);
    }
  }

  void _onSearchChanged() {
    final query = widget.queryController.text;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (query.isEmpty) {
        setState(() {
          _hotels.clear();
          _currentPage = 1;
          _hasMore = true;
          _errorMessage = null;
          _initialLoaded = false;
        });
        return;
      }

      if (query.length < 3) {
        return;
      }

      _fetchHotels(query, reset: true);
    });
  }

  Future<void> _fetchHotels(String query, {bool reset = false}) async {
    if (query.isEmpty) return;

    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _hotels.clear();
      _errorMessage = null;
    }

    if (!_hasMore) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final results = await _hotelService
          .fetchHotels(query, page: _currentPage)
          .timeout(
            const Duration(seconds: 18),
            onTimeout: () => throw TimeoutException('Search request timed out'),
          );

      setState(() {
        if (reset) _hotels.clear();
        _hotels.addAll(results);
        _hasMore = results.length == HotelService.pageSize;
        _currentPage++;
        _initialLoaded = true;
      });
    } on TimeoutException {
      setState(
        () => _errorMessage =
            'Request timed out. Please check your connection and try again.',
      );
    } catch (e) {
      var msg = 'Failed to fetch hotels. Try again.';
      final se = e.toString();
      if (se.contains('429'))
        msg = 'Rate limit reached. Try again after a short while.';
      if (se.contains('status')) msg = 'Server error while fetching results.';
      setState(() => _errorMessage = msg);
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
      body: _loading && !_initialLoaded
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
      textInputAction: TextInputAction.search,
      onSubmitted: (v) {
        if (v.trim().length >= 3) {
          _fetchHotels(v.trim(), reset: true);
        }
      },
    );
  }

  Widget _buildHotelList() {
    return RefreshIndicator(
      onRefresh: () => _fetchHotels(widget.queryController.text, reset: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 80 &&
              !_loading &&
              _hasMore) {
            _fetchHotels(widget.queryController.text);
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
    if (widget.queryController.text.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search hotels',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return const Center(
      child: Text(
        'No results found',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          _errorMessage ?? 'Unknown error',
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
