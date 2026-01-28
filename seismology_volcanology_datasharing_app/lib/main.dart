import 'package:flutter/material.dart';

import 'screens/timeline.dart';
import 'utils_services/mock_data_updater.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Update mock data with recent timestamps if needed
  if (await MockDataUpdater.shouldUpdateMockData()) {
    await MockDataUpdater.updateMockDataTimestamps();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seismology/Volcanology Datasharing App',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

      // ),
      home: const HomePage(),
    );
  }
}


