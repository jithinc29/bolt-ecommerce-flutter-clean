import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final double? initialMin;
  final double? initialMax;
  final Function(double?, double?) onApply;

  const FilterDialog({
    super.key,
    this.initialMin,
    this.initialMax,
    required this.onApply,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late RangeValues _currentRange;
  final double _minLimit = 0;
  final double _maxLimit = 10000;

  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(
      widget.initialMin ?? _minLimit,
      widget.initialMax ?? _maxLimit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter by Price'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_currentRange.start.round()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '\$${_currentRange.end.round()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RangeSlider(
            values: _currentRange,
            min: _minLimit,
            max: _maxLimit,
            divisions: 100,
            labels: RangeLabels(
              '\$${_currentRange.start.round()}',
              '\$${_currentRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _currentRange = values;
              });
            },
          ),
          Text(
            'Price Range: \$${_currentRange.start.round()} - \$${_currentRange.end.round()}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _currentRange = RangeValues(_minLimit, _maxLimit);
            });
          },
          child: const Text('Reset'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_currentRange.start, _currentRange.end);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
