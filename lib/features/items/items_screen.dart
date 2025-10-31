import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import 'package:my_app/data/models/item_model.dart';
import 'package:my_app/providers/item_provider.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      itemProvider.fetchItemsData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      Image.asset('assets/logo_outline.png'),
                      Text(
                        'Inventory Management',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    'Manage your inventory items',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ShadButton(
                onPressed: () {},
                leading: Icon(Icons.add, color: Colors.white, size: 16),
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        // elevation: 0.5,
      ),
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, child) {
          if (itemProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (itemProvider.itemData == null || itemProvider.itemData!.isEmpty) {
            return Center(
              child: Text(
                itemProvider.errorMessage.isNotEmpty
                    ? itemProvider.errorMessage
                    : 'No items found',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final List<ItemModel> items = itemProvider.itemData!;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Item Name')),
                        DataColumn(label: Text('SKU')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: items
                          .map(
                            (item) => DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (states) => items.indexOf(item) % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.shade50,
                              ),
                              cells: [
                                DataCell(Text(item.id.toString())),
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
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
