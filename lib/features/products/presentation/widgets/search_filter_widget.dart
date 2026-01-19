import 'dart:async';
import 'package:flutter/material.dart';
import 'filter_dialog.dart';

class SearchFilterWidget extends StatefulWidget {
  final String? initialSearch;
  final Function(String) onSearchChanged;
  final Function(double?, double?) onFilterApplied;
  final double? minPrice;
  final double? maxPrice;

  const SearchFilterWidget({
    super.key,
    this.initialSearch,
    required this.onSearchChanged,
    required this.onFilterApplied,
    this.minPrice,
    this.maxPrice,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSearch);
  }

  @override
  void didUpdateWidget(covariant SearchFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.initialSearch ?? '';
    if (nextText != _controller.text) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => FilterDialog(
                    initialMin: widget.minPrice,
                    initialMax: widget.maxPrice,
                    onApply: widget.onFilterApplied,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
