import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_app/core/constants/app_constants.dart';
import 'package:my_app/data/models/item_model.dart';
import 'package:my_app/service/api_service.dart';
import 'package:my_app/widgets/shad_alert_dialog.dart';
import 'package:provider/provider.dart';

class ItemProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  late ApiService _apiService;
  List<ItemModel>? _itemData;
  String _searchQuery = '';

  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  List<ItemModel>? get itemData => _itemData; // ✅ Public getter

  Future<void> _initializeProfileProvider() async {
    _apiService = ApiService(baseUrl: AppConstants.hostServer);
    notifyListeners();
  }

  // void setWordPronunciationScore(int wordId, String score) {
  //   // Add this method
  //   _wordPronunciationScores[wordId] = score;
  //   notifyListeners(); // Ensure UI updates
  // }

  Future<void> fetchItemsData(BuildContext context, String? searchQuery) async {
    _initializeProfileProvider();
    _isLoading = true;
    _errorMessage = '';
    String uri;
    notifyListeners();
    try {
      uri = '/items';
      final response = await _apiService.get(
        uri,
        queryParams: {'search': searchQuery},
      );
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

  Future<void> deleteItem(BuildContext context, int itemId) async {
    _isLoading = true;
    notifyListeners(); // Notify listeners that loading has started
    try {
      final response = await _apiService.delete('/items/$itemId');
      final statusCode = response['statusCode'].toString();
      final responseError = response['message'].toString();
      print(response);
      if (statusCode != "200") {
        // Handle other errors
        _errorMessage = 'Delete Item failed';
        ShadAlertDialog.showAlertDialogWarning(
          context,
          'Delete Item failed',
          responseError,
        );
      } else {
        // Success case
        _successMessage = 'Delete Item Success';
        _errorMessage = '';

        final itemProvider = Provider.of<ItemProvider>(context, listen: false);
        // Update with empty array since delete was successful
        itemProvider.fetchItemsData(context, '');
      }
    } catch (e) {
      // Handle unexpected errors
      _errorMessage = 'Delete Item failed';
      ShadAlertDialog.showAlertDialogWarning(
        context,
        'Delete Item failed',
        e.toString(),
      );
      log('Error during Delete Item: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners that loading has finished
    }
  }
}
