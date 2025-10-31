import 'package:flutter/material.dart';
import 'package:my_app/features/items/items_screen.dart';
import 'package:my_app/providers/item_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => ItemProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      // 🌗 You can toggle between light/dark/system themes
      themeMode: ThemeMode.system,

      // 💡 Define the default theme and dark theme
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
      ),

      // 🧱 Integrate MaterialApp inside ShadApp
      appBuilder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shadcn + Material Demo',
          theme: Theme.of(context), // inherit the Shad theme
          home: const ItemsScreen(),
          builder: (context, child) {
            // Ensure ShadAppBuilder wraps your app
            return ShadAppBuilder(child: child!);
          },
        );
      },
    );
  }
}
