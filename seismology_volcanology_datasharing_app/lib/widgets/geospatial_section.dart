import 'package:flutter/material.dart';
import '../controllers/filter_controller.dart';

class GeospatialSection extends StatelessWidget {
  final FilterController controller;

  const GeospatialSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'geospatial category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...controller.state.geospatialCategories.entries.map((entry) {
              return CheckboxListTile(
                value: entry.value,
                onChanged: (value) {
                  controller.setGeospatialCategory(entry.key, value ?? false);
                },
                title: Text(entry.key, style: const TextStyle(fontSize: 11)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
          ],
        );
      },
    );
  }
}