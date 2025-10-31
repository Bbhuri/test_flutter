import 'package:flutter/material.dart';
import 'package:my_app/features/items/items_screen.dart';
import 'package:my_app/features/items/manage_item_screen.dart';

class AppRoutes {
  static const String items = '/items';
  static const String manageItemsScreen = '/manage_items_screen';

  // ฟังก์ชันนี้จะคืนค่าเป็น Widget ตามเส้นทาง
  static Widget getScreen(String routeName) {
    switch (routeName) {
      case items:
        return const ItemsScreen();
      case manageItemsScreen:
        return const ManageItemScreen();
      default:
        return const ItemsScreen(); // Default screen
    }
  }
}
