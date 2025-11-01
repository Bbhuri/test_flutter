import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/core/routes/push_route.dart';
import 'package:my_app/features/items/manage_item_screen.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:my_app/data/models/item_model.dart';
import 'package:my_app/providers/item_provider.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String searchQuery = '';
  Timer? _debounce;
  final Set<int> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    // 🧭 Fetch data once when widget mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = context.read<ItemProvider>();
      itemProvider.fetchItemsData(context, '');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => searchQuery = value);

    // 🕒 Debounce search to avoid multiple rebuilds
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final itemProvider = context.read<ItemProvider>();
      itemProvider.fetchItemsData(context, searchQuery);
    });
  }

  Future<void> _deleteSelectedItems() async {
    final itemProvider = context.read<ItemProvider>();
    for (final id in _selectedItems) {
      await itemProvider.deleteItem(context, id);
    }
    setState(() {
      _selectedItems.clear();
    });
    // Refresh data after deletion
    await itemProvider.fetchItemsData(context, searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo_outline.png', height: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Inventory Management',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Manage your inventory items',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ShadButton(
                onPressed: () {
                  // 👇 Navigate with slide animation
                  pushWithAnimation(context, const ManageItemScreen());
                },

                leading: const Icon(Icons.add, color: Colors.white, size: 16),
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),

      // 🧱 Main content
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by Item name, Category, or Status...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 20),
                Visibility(
                  visible: _selectedItems.isNotEmpty,
                  child: ShadButton.destructive(
                    onPressed: _selectedItems.isEmpty
                        ? null
                        : () {
                            _deleteSelectedItems();
                          },
                    child: const Text('Delete Selected'),
                  ),
                ),
              ],
            ),

            // 🔍 Search bar
            const SizedBox(height: 20),

            // 📦 Data Table
            Expanded(
              child: Builder(
                builder: (_) {
                  if (itemProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemProvider.itemData == null ||
                      itemProvider.itemData!.isEmpty) {
                    return Center(
                      child: Text(
                        itemProvider.errorMessage.isNotEmpty
                            ? itemProvider.errorMessage
                            : 'No items found',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  final items = itemProvider.itemData!;

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical, // vertical scroll
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.grey.shade100,
                          ),

                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          border: TableBorder.all(
                            color: Colors.grey.shade200,
                            width: 1,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          columns: [
                            DataColumn(
                              label: Checkbox(
                                value:
                                    _selectedItems.length == items.length &&
                                    items.isNotEmpty,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedItems.addAll(
                                        items.map((e) => e.id),
                                      );
                                    } else {
                                      _selectedItems.clear();
                                    }
                                  });
                                },
                              ),
                            ),

                            DataColumn(label: Text('Item Name')),
                            DataColumn(label: Text('SKU')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: items.map((item) {
                            final isSelected = _selectedItems.contains(item.id);

                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (states) => items.indexOf(item) % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.shade50,
                              ),
                              onSelectChanged: (selected) {
                                if (selected == true) {
                                  pushWithAnimation(
                                    context,
                                    ManageItemScreen(
                                      item: item,
                                    ), // pass current item to edit
                                  );
                                }
                              },
                              cells: [
                                DataCell(
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedItems.add(item.id);
                                        } else {
                                          _selectedItems.remove(item.id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                DataCell(Text(item.itemName)),
                                DataCell(Text(item.sku)),
                                DataCell(Text(item.category ?? '-')),
                                DataCell(Text(item.quantity.toString())),
                                DataCell(Text(item.price.toStringAsFixed(2))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        item.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.status.value,
                                      style: TextStyle(
                                        color: _statusColor(item.status),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.inStock:
        return Colors.green;
      case ItemStatus.lowStock:
        return Colors.orange;
      case ItemStatus.outOfStock:
        return Colors.red;
    }
  }
}
