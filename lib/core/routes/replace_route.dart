import 'package:flutter/material.dart';

void removeAndReplaceWithAnimation(BuildContext context, Widget newScreen) {
  Navigator.of(context).pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return newScreen;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);
        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    ),
    (route) => false, // ✅ ลบ `route` ทั้งหมด
  );
}
