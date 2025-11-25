import 'package:flutter/material.dart';

typedef OnFloorChanged = void Function(String floor);

class FloorSelector extends StatefulWidget {
  final List<String> floors;
  final String? initial;
  final OnFloorChanged? onChanged;

  const FloorSelector({
    super.key,
    this.floors = const ['Ground', '1st', '2nd', '3rd', 'Top'],
    this.initial = "Ground",
    this.onChanged,
  });

  @override
  _FloorSelectorState createState() => _FloorSelectorState();
}

class _FloorSelectorState extends State<FloorSelector> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...widget.floors.map((f) {
          final isSelected = _selected == f;
          return ChoiceChip(
            label: Text(f),
            selected: isSelected,
            onSelected: (sel) {
              setState(() => _selected = sel ? f : null);
              widget.onChanged?.call(_selected ?? '');
            },
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          );
        }),

        // 🔥 This is now VALID because children list is List<Widget>
        ActionChip(
          label: const Text('Other'),
          onPressed: () async {
            final other = await _showOtherFloorDialog(context);
            if (other != null && other.trim().isNotEmpty) {
              setState(() => _selected = other.trim());
              widget.onChanged?.call(_selected ?? '');
            }
          },
        ),
      ],
    );
  }

  Future<String?> _showOtherFloorDialog(BuildContext context) {
    final ctrl = TextEditingController(text: _selected);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter floor'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'e.g. 4th / Mezzanine'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
