import 'package:flutter/material.dart';
import '../supabase_config.dart';
import 'cart_screen.dart';
import 'wiiv_loyalty_screen.dart';
import 'login_screen.dart';
import 'vouchers_screen.dart';
import 'brochure_screen.dart';
import 'dart:ui';

class CustomerHomeScreen
    extends
        StatefulWidget {
  final Map<
    String,
    dynamic
  >
  userProfile;

  const CustomerHomeScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<
    CustomerHomeScreen
  >
  createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState
    extends
        State<
          CustomerHomeScreen
        > {
  final _supabase = SupabaseConfig.client;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<
    Map<
      String,
      dynamic
    >
  >
  _cart = [];
  bool _showAntiGaspillageOnly = false;

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

  void _addToCart(
    Map<
      String,
      dynamic
    >
    product,
  ) {
    setState(
      () {
        final index = _cart.indexWhere(
          (
            item,
          ) =>
              item['id'] ==
              product['id'],
        );
        if (index >=
            0) {
          _cart[index]['quantity']++;
        } else {
          _cart.add(
            {
              ...product,
              'quantity': 1,
            },
          );
        }
      },
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          '${product['name']} added to basket',
        ),
        duration: const Duration(
          seconds: 1,
        ),
      ),
    );
  }

  // Navigation handlers to open full screens
  void _openVouchersScreen(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (
              _,
            ) => const VouchersScreen(),
      ),
    );
  }

  void _openBrochureScreen(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (
              _,
            ) => const BrochureScreen(),
      ),
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
        backgroundColor: winnersGreen,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Winners Online',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Hello, ${widget.userProfile['full_name'] ?? 'Customer'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          // Weekly Brochure Icon Button
          IconButton(
            icon: const Icon(
              Icons.menu_book_rounded,
            ),
            tooltip: 'Weekly Brochure',
            onPressed: () => _openBrochureScreen(
              context,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.card_membership_rounded,
            ),
            tooltip: 'Wiiv Card',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        _,
                      ) => WiivLoyaltyScreen(
                        userProfile: widget.userProfile,
                      ),
                ),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            _,
                          ) => CartScreen(
                            cartItems: _cart,
                            userProfile: widget.userProfile,
                            onOrderCompleted: () => setState(
                              () => _cart.clear(),
                            ),
                          ),
                    ),
                  );
                },
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      '${_cart.fold<int>(0, (sum, item) => sum + (item['quantity'] as int))}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () async {
              await _supabase.auth.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (
                          _,
                        ) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter Actions Banner
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: Column(
              children: [
                TextField(
                  onChanged:
                      (
                        val,
                      ) => setState(
                        () => _searchQuery = val.toLowerCase(),
                      ),
                  decoration: InputDecoration(
                    hintText: 'Search products in Winners...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: winnersGreen,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    // Horizontal Scrollable Action Chips
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // 1. Anti-Gaspillage Filter
                            FilterChip(
                              selected: _showAntiGaspillageOnly,
                              avatar: const Icon(
                                Icons.eco,
                                size: 16,
                                color: Colors.green,
                              ),
                              label: const Text(
                                'Anti-Gaspillage Deals',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selectedColor: Colors.amber.shade200,
                              onSelected:
                                  (
                                    val,
                                  ) => setState(
                                    () => _showAntiGaspillageOnly = val,
                                  ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),

                            // 2. Vouchers Chip
                            ActionChip(
                              avatar: const Icon(
                                Icons.confirmation_number_outlined,
                                size: 16,
                                color: Colors.deepPurple,
                              ),
                              label: const Text(
                                'Vouchers',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.purple.shade50,
                              onPressed: () => _openVouchersScreen(
                                context,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),

                            // 3. Weekly Brochure Chip
                            ActionChip(
                              avatar: const Icon(
                                Icons.menu_book_rounded,
                                size: 16,
                                color: Colors.teal,
                              ),
                              label: const Text(
                                'Brochure',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.teal.shade50,
                              onPressed: () => _openBrochureScreen(
                                context,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Wiiv Pts: ${widget.userProfile['wiiv_points'] ?? 0}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: winnersGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Categories Scroll bar
          SizedBox(
            height: 44,
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(
                    context,
                  ).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                itemCount: _categories.length,
                itemBuilder:
                    (
                      context,
                      index,
                    ) {
                      final cat = _categories[index];
                      final isSelected =
                          cat ==
                          _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                          ),
                          selected: isSelected,
                          selectedColor: winnersGreen,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected:
                              (
                                _,
                              ) => setState(
                                () => _selectedCategory = cat,
                              ),
                        ),
                      );
                    },
              ),
            ),
          ),

          // Real-time Responsive Product Grid
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
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading products: ${snapshot.error}',
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var products = snapshot.data!;

                        if (_selectedCategory !=
                            'All') {
                          products = products
                              .where(
                                (
                                  p,
                                ) =>
                                    p['category'] ==
                                    _selectedCategory,
                              )
                              .toList();
                        }
                        if (_showAntiGaspillageOnly) {
                          products = products
                              .where(
                                (
                                  p,
                                ) =>
                                    p['is_anti_gaspillage'] ==
                                    true,
                              )
                              .toList();
                        }
                        if (_searchQuery.isNotEmpty) {
                          products = products
                              .where(
                                (
                                  p,
                                ) => p['name'].toString().toLowerCase().contains(
                                  _searchQuery,
                                ),
                              )
                              .toList();
                        }

                        if (products.isEmpty) {
                          return const Center(
                            child: Text(
                              'No products available right now.',
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(
                            12,
                          ),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisExtent: 265,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: products.length,
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final item = products[index];
                                final bool isAntiGasp =
                                    item['is_anti_gaspillage'] ??
                                    false;
                                final String? imgUrl = item['image_url'];
                                final int stock =
                                    item['stock_quantity'] ??
                                    0;

                                return Card(
                                  elevation: 3,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          SizedBox(
                                            height: 110,
                                            width: double.infinity,
                                            child:
                                                imgUrl !=
                                                        null &&
                                                    imgUrl.isNotEmpty
                                                ? Image.network(
                                                    imgUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => Container(
                                                          color: Colors.grey.shade200,
                                                          child: const Icon(
                                                            Icons.shopping_bag,
                                                            size: 40,
                                                            color: winnersGreen,
                                                          ),
                                                        ),
                                                  )
                                                : Container(
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(
                                                      Icons.shopping_bag,
                                                      size: 40,
                                                      color: winnersGreen,
                                                    ),
                                                  ),
                                          ),
                                          if (isAntiGasp)
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.shade800,
                                                  borderRadius: BorderRadius.circular(
                                                    6,
                                                  ),
                                                ),
                                                child: const Text(
                                                  '♻️ Anti-Gasp',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            8.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['name'] ??
                                                        '',
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Rs ${item['price'] ?? 0}',
                                                        style: const TextStyle(
                                                          color: winnersGreen,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      if (isAntiGasp &&
                                                          item['original_price'] !=
                                                              null) ...[
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Rs ${item['original_price']}',
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.grey,
                                                            decoration: TextDecoration.lineThrough,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  Text(
                                                    'Stock: $stock',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: winnersGreen,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                  ),
                                                  onPressed:
                                                      stock >
                                                          0
                                                      ? () => _addToCart(
                                                          item,
                                                        )
                                                      : null,
                                                  icon: const Icon(
                                                    Icons.add_shopping_cart,
                                                    size: 14,
                                                  ),
                                                  label: const Text(
                                                    'Add',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
    );
  }
}
