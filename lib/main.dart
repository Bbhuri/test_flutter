import 'package:flutter/material.dart';
import 'package:my_app/features/items/items_screen.dart';
import 'package:my_app/providers/item_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => ItemProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ItemsScreen());
  }
}
