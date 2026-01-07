import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey[300],
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('Filters'),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search events, volcanoes, locations...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          _iconButton(Icons.info_outline, 'Tutorial'),
          _iconButton(Icons.bookmark_border, 'Bookmarks'),
          _iconButton(Icons.download_outlined, 'Export'),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
