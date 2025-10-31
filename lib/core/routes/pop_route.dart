import 'package:flutter/material.dart';

void popWithAnimation(BuildContext context) {
  Navigator.pop(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox(); // Dummy widget
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation แบบ fade out
        var fadeAnimation = Tween(begin: 1.0, end: 0.0).animate(animation);
        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    ),
  );
}
