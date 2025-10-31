import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_app/core/constants/app_constants.dart';
import 'package:my_app/data/models/item_model.dart';
import 'package:my_app/service/api_service.dart';

class ItemProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  late ApiService _apiService;
  List<ItemModel>? _itemData;

  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<ItemModel>? get itemData => _itemData; // ✅ Public getter

  Future<void> _initializeProfileProvider() async {
    _apiService = ApiService(baseUrl: AppConstants.hostServer);
    notifyListeners();
  }

  Future<void> fetchItemsData(BuildContext context) async {
    _initializeProfileProvider();
    _isLoading = true;
    _errorMessage = '';
    String uri;
    notifyListeners();
    try {
      Map<String, dynamic>? params;

      uri = '/items';

      final response = await _apiService.get(uri, queryParams: params);
      if (response['statusCode'] == 200) {
        final List<ItemModel> items = itemListFromJson(response['data']);
        _itemData = items;
        // print(items);
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch items data';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      log("Error : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
