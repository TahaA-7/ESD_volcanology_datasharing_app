import 'package:flutter/material.dart';
import '../screens/event_post_wizard.dart';

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
            onPressed: () {
              // TODO: open filters panel / drawer
            },
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('Filters'),
          ),

          const SizedBox(width: 12),

          // Search box
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

          _iconButton(Icons.info_outline, 'Tutorial', onPressed: () {}),
          _iconButton(Icons.bookmark_border, 'Bookmarks', onPressed: () {}),
          _iconButton(Icons.download_outlined, 'Export', onPressed: () {}),
          _iconButton(
            Icons.post_add,
            'Post',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const EventPostWizardScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon,
    String label, {
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
