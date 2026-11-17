import 'package:flutter/material.dart';
import '../supabase_config.dart';
import 'login_screen.dart';

class AdminDashboardScreen
    extends
        StatefulWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  State<
    AdminDashboardScreen
  >
  createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends
        State<
          AdminDashboardScreen
        > {
  final _supabase = SupabaseConfig.client;

  // Track selected category filter ('All' shows everything)
  String _selectedCategoryFilter = 'All';

  final List<
    String
  >
  _categories = [
    'All',
    'Fresh Produce',
    'Bakery',
    'Dairy & Chilled',
    'Meat & Poultry',
    'Fish & Seafood',
    'Frozen Foods',
    'Rice & Pasta',
    'Breakfast',
    'Tea & Coffee',
    'Cooking Oil',
    'Canned Goods',
    'Snacks',
    'Biscuits',
    'Chocolate',
    'Soft Drinks',
    'Juices',
    'Water',
    'Condiments & Sauces',
    'Spices',
    'Household',
    'Laundry',
    'Cleaning',
    'Personal Care',
    'Health & Beauty',
    'Baby Care',
    'Pet Care',
  ];

  void _showProductDialog([
    Map<
      String,
      dynamic
    >?
    product,
  ]) {
    final nameCtrl = TextEditingController(
      text:
          product !=
              null
          ? product['name']
          : '',
    );
    final priceCtrl = TextEditingController(
      text:
          product !=
              null
          ? product['price'].toString()
          : '',
    );
    final stockCtrl = TextEditingController(
      text:
          product !=
              null
          ? product['stock_quantity'].toString()
          : '',
    );
    final imgCtrl = TextEditingController(
      text:
          product !=
              null
          ? product['image_url']
          : '',
    );

    String category =
        product !=
            null
        ? product['category']
        : 'Fresh Produce';
    bool isAntiGasp =
        product !=
            null
        ? (product['is_anti_gaspillage'] ??
              false)
        : false;

    showDialog(
      context: context,
      builder:
          (
            context,
          ) {
            return StatefulBuilder(
              builder:
                  (
                    context,
                    setDialogState,
                  ) {
                    return AlertDialog(
                      title: Text(
                        product ==
                                null
                            ? 'Create New Item'
                            : 'Edit Product',
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Item Name',
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextField(
                              controller: stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantity in Stock',
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextField(
                              controller: priceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Price (MUR)',
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextField(
                              controller: imgCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Image URL',
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            DropdownButtonFormField<
                              String
                            >(
                              value: category,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                              ),
                              items: _categories
                                  .where(
                                    (
                                      c,
                                    ) =>
                                        c !=
                                        'All',
                                  )
                                  .map(
                                    (
                                      c,
                                    ) =>
                                        DropdownMenuItem<
                                          String
                                        >(
                                          value: c,
                                          child: Text(
                                            c,
                                          ),
                                        ),
                                  )
                                  .toList(),
                              onChanged:
                                  (
                                    val,
                                  ) {
                                    setDialogState(
                                      () {
                                        category = val!;
                                      },
                                    );
                                  },
                            ),
                            SwitchListTile(
                              title: const Text(
                                'Anti-Gaspillage Deal',
                              ),
                              value: isAntiGasp,
                              onChanged:
                                  (
                                    val,
                                  ) => setDialogState(
                                    () => isAntiGasp = val,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(
                            context,
                          ),
                          child: const Text(
                            'Cancel',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            final price =
                                double.tryParse(
                                  priceCtrl.text,
                                ) ??
                                0.0;
                            final stock =
                                int.tryParse(
                                  stockCtrl.text,
                                ) ??
                                0;
                            final imgUrl = imgCtrl.text.trim();

                            if (name.isEmpty) return;

                            if (product ==
                                null) {
                              await _supabase
                                  .from(
                                    'products',
                                  )
                                  .insert(
                                    {
                                      'name': name,
                                      'price': price,
                                      'stock_quantity': stock,
                                      'category': category,
                                      'image_url': imgUrl,
                                      'is_anti_gaspillage': isAntiGasp,
                                    },
                                  );
                            } else {
                              await _supabase
                                  .from(
                                    'products',
                                  )
                                  .update(
                                    {
                                      'name': name,
                                      'price': price,
                                      'stock_quantity': stock,
                                      'category': category,
                                      'image_url': imgUrl,
                                      'is_anti_gaspillage': isAntiGasp,
                                    },
                                  )
                                  .eq(
                                    'id',
                                    product['id'],
                                  );
                            }

                            if (context.mounted)
                              Navigator.pop(
                                context,
                              );
                          },
                          child: const Text(
                            'Save',
                          ),
                        ),
                      ],
                    );
                  },
            );
          },
    );
  }

  void _deleteProduct(
    int id,
  ) async {
    await _supabase
        .from(
          'products',
        )
        .delete()
        .eq(
          'id',
          id,
        );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    const winnersGreen = Color(
      0xFF008751,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Winners Stock Management',
        ),
        backgroundColor: winnersGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () {
              _supabase.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        _,
                      ) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header & Category Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Items in Stock',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.inventory_2_outlined,
                      color: winnersGreen,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                // Horizontal category filter chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder:
                        (
                          _,
                          __,
                        ) => const SizedBox(
                          width: 8,
                        ),
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final cat = _categories[index];
                          final isSelected =
                              _selectedCategoryFilter ==
                              cat;
                          return ChoiceChip(
                            label: Text(
                              cat,
                            ),
                            selected: isSelected,
                            selectedColor: winnersGreen,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected:
                                (
                                  selected,
                                ) {
                                  setState(
                                    () {
                                      _selectedCategoryFilter = cat;
                                    },
                                  );
                                },
                          );
                        },
                  ),
                ),
              ],
            ),
          ),

          // Product List Stream
          Expanded(
            child:
                StreamBuilder<
                  List<
                    Map<
                      String,
                      dynamic
                    >
                  >
                >(
                  stream: _supabase
                      .from(
                        'products',
                      )
                      .stream(
                        primaryKey: [
                          'id',
                        ],
                      ),
                  builder:
                      (
                        context,
                        snapshot,
                      ) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final allProducts = snapshot.data!;

                        // Filter products based on selected category chip
                        final products =
                            _selectedCategoryFilter ==
                                'All'
                            ? allProducts
                            : allProducts
                                  .where(
                                    (
                                      p,
                                    ) =>
                                        p['category'] ==
                                        _selectedCategoryFilter,
                                  )
                                  .toList();

                        if (products.isEmpty) {
                          return Center(
                            child: Text(
                              'No items found in "$_selectedCategoryFilter"',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: products.length,
                          separatorBuilder:
                              (
                                _,
                                __,
                              ) => const Divider(
                                height: 1,
                              ),
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final item = products[index];
                                return ListTile(
                                  leading: Image.network(
                                    item['image_url'] ??
                                        '',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                          _,
                                          __,
                                          ___,
                                        ) => const Icon(
                                          Icons.shopping_bag,
                                          color: winnersGreen,
                                        ),
                                  ),
                                  title: Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Qty: ${item['stock_quantity']} | Cat: ${item['category']}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Rs ${item['price']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: winnersGreen,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _showProductDialog(
                                          item,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteProduct(
                                          item['id'],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        );
                      },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: winnersGreen,
        onPressed: () => _showProductDialog(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
