import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/core/routes/push_route.dart';
import 'package:my_app/features/items/items_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:my_app/data/models/item_model.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/item_provider.dart';

class ManageItemScreen extends StatefulWidget {
  final ItemModel? item; // null → add mode

  const ManageItemScreen({super.key, this.item});

  @override
  State<ManageItemScreen> createState() => _ManageItemScreenState();
}

class _ManageItemScreenState extends State<ManageItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _itemNameCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _priceCtrl;
  late String _status;
  double _totalValue = 0.0;

  bool get isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _itemNameCtrl = TextEditingController(text: item?.itemName ?? '');
    _skuCtrl = TextEditingController(text: item?.sku ?? '');
    _categoryCtrl = TextEditingController(text: item?.category ?? '');
    _descriptionCtrl = TextEditingController(text: item?.description ?? '');
    _quantityCtrl = TextEditingController(
      text: item?.quantity.toString() ?? '0',
    );
    _priceCtrl = TextEditingController(text: item?.price.toString() ?? '0.00');
    _status = item?.status.value ?? 'IN_STOCK';
  }

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _skuCtrl.dispose();
    _categoryCtrl.dispose();
    _descriptionCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final itemProvider = context.read<ItemProvider>();

    final newItem = ItemModel(
      id: widget.item?.id ?? 0,
      itemName: _itemNameCtrl.text.trim(),
      sku: _skuCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      quantity: int.tryParse(_quantityCtrl.text) ?? 0,
      price: double.tryParse(_priceCtrl.text) ?? 0.0,
      status: ItemStatusExtension.fromValue(_status),
    );
    print('New Item: ${newItem.status}');
    print('New Item: $newItem');
    if (isEditMode) {
      await itemProvider.updateItem(context, newItem);
    } else {
      await itemProvider.createItem(context, newItem);
    }
  }

  void _deleteItem() async {
    if (widget.item == null) return;
    final itemProvider = context.read<ItemProvider>();
    await itemProvider.deleteItem(context, widget.item!.id);
    pushWithAnimation(context, const ItemsScreen());
  }

  void _calculateTotalValue() {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    setState(() {
      _totalValue = qty * price;
    });
  }

  String get _stockLevel {
    final qty = int.tryParse(_quantityCtrl.text) ?? 0;
    if (qty == 0) return 'Critical';
    if (qty < 10) return 'Low';
    return 'Healthy';
  }

  Color get _stockColor {
    final qty = int.tryParse(_quantityCtrl.text) ?? 0;
    if (qty == 0) return Colors.red;
    if (qty < 10) return Colors.orange;
    return Colors.green;
  }

  final status = {
    'IN_STOCK': 'In Stock',
    'LOW_STOCK': 'Low Stock',
    'OUT_OF_STOCK': 'Out of Stock',
  };

  @override
  Widget build(BuildContext context) {
    final title = isEditMode ? 'Item Details' : 'Create New Item';
    final subtitle = isEditMode
        ? 'Edit item information'
        : 'Add a new item to your inventory';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          if (isEditMode)
            ShadButton.destructive(
              onPressed: _deleteItem,
              leading: const ImageIcon(
                AssetImage('assets/trash.png'),
                color: Colors.white,
                size: 16,
              ),
              child: const Text('Delete'),
            ),
          const SizedBox(width: 8),
          ShadButton(
            onPressed: _saveItem,
            leading: ImageIcon(
              AssetImage(isEditMode ? 'assets/disk.png' : 'assets/plus.png'),
              color: Colors.white,
              size: 16,
            ),
            child: Text(isEditMode ? 'Save Changes' : 'Create Item'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔹 Basic Information
                ShadCard(
                  title: const Text('Basic Information'),
                  description: const Text('Essential item details'),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Item Name *',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                ShadInput(
                                  placeholder: Text('e.g., Wireless Mouse'),
                                  controller: _itemNameCtrl,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SKU *',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                ShadInput(
                                  placeholder: Text('e.g., WM-001'),
                                  controller: _skuCtrl,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category'),
                          const SizedBox(height: 6),
                          ShadInput(
                            placeholder: Text('e.g., Electronics'),
                            controller: _categoryCtrl,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Description'),
                          const SizedBox(height: 6),
                          ShadInput(
                            placeholder: Text(
                              'Enter a detailed description...',
                            ),
                            controller: _descriptionCtrl,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // 🔹 Inventory Details
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 36,
                      child: ShadCard(
                        title: const Text('Preview'),
                        description: const Text('How your item will appear'),
                        child: Column(
                          children: [
                            SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Quantity'),
                                const SizedBox(height: 6),
                                ShadInput(
                                  placeholder: Text('e.g., 100'),
                                  controller: _quantityCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly, // ✅ only allows 0–9
                                  ],
                                  onChanged: (value) => _calculateTotalValue(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Price'),
                                const SizedBox(height: 6),
                                ShadInput(
                                  placeholder: Text('e.g., 99.99'),
                                  controller: _priceCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ),
                                  ],
                                  onChanged: (value) => _calculateTotalValue(),
                                  leading: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      '\$',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2 -
                                      70, // set width in pixels
                                  height: 45, // optional
                                  child: StatusSelect(
                                    key: ValueKey(_status),
                                    initialValue: _status,
                                    onChanged: (value) {
                                      if (value == null)
                                        return; // don’t write an empty string
                                      setState(
                                        () => _status = value,
                                      ); // keep it in state
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 36,
                      child: ShadCard(
                        title: const Text('Item Summary'),
                        description: Text(
                          widget.item?.id != null
                              ? 'Current item details'
                              : "How your item will appear",
                        ),
                        child: widget.item?.id != null
                            ? Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('ID: '),
                                          Text('${widget.item?.id.toString()}'),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                        height: 24,
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,

                                        children: [
                                          Text('Total Value: '),
                                          Text(
                                            '\$${_totalValue.toStringAsFixed(2)}',
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                        height: 24,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween, // 👈 evenly separates left/right

                                        children: [
                                          Text('Stock Level: '),
                                          Text(
                                            _stockLevel,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: _stockColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1, // line thickness
                                        height:
                                            24, // space above and below the line
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 121),
                                ],
                              )
                            : Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .grey
                                          .shade100, // 👈 light grey background
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ), // optional rounded corners
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Item Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Text('SKU: N/A'),
                                        const Text('Category: Uncategorized'),
                                        Divider(
                                          color: Colors.grey.shade300,
                                          thickness: 1,
                                          height: 24,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Quantity: '),
                                            Text(
                                              _quantityCtrl.text.isEmpty
                                                  ? '0'
                                                  : _quantityCtrl.text,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,

                                          children: [
                                            Text('Price: '),
                                            Text(
                                              _priceCtrl.text.isEmpty
                                                  ? '\$0.00'
                                                  : '\$${_priceCtrl.text}',
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Total Value: '),
                                            Text(
                                              '\$${_totalValue.toStringAsFixed(2)}',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        208,
                                        223,
                                        255,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          100,
                                          116,
                                          255,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const ImageIcon(
                                          AssetImage('assets/information.png'),
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            'Tip: Make sure to fill in all the required fields before creating the item.',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final status = {
  'IN_STOCK': 'In Stock',
  'LOW_STOCK': 'Low Stock',
  'OUT_OF_STOCK': 'Out of Stock',
};

class StatusSelect extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String?> onChanged;

  const StatusSelect({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: ShadSelect<String>(
        placeholder: const Text('Select status'),
        options: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
            child: Text(
              'Status Options',
              style: theme.textTheme.muted.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.popoverForeground,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          ...status.entries.map(
            (entry) => ShadOption(value: entry.key, child: Text(entry.value)),
          ),
        ],
        selectedOptionBuilder: (context, value) =>
            Text(status[value] ?? 'Select status'),
        initialValue: initialValue,
        onChanged: onChanged,
      ),
    );
  }
}
