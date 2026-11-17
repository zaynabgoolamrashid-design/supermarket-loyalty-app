import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../supabase_config.dart';

class CartScreen
    extends
        StatefulWidget {
  final List<
    Map<
      String,
      dynamic
    >
  >
  cartItems;
  final Map<
    String,
    dynamic
  >
  userProfile;
  final VoidCallback onOrderCompleted;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.userProfile,
    required this.onOrderCompleted,
  });

  @override
  State<
    CartScreen
  >
  createState() => _CartScreenState();
}

class _CartScreenState
    extends
        State<
          CartScreen
        > {
  final _supabase = SupabaseConfig.client;
  final TextEditingController _voucherController = TextEditingController();

  String _fulfillmentType = 'Click & Collect';
  String _selectedStore = 'Winners Phoenix Mall';
  bool _isProcessing = false;

  // --- VOUCHER STATE VARIABLES ---
  double _discountAmount = 0.0;
  String? _appliedVoucherCode;

  final List<
    String
  >
  _winnersStores = [
    'Winners Phoenix Mall',
    'Winners Cascavelle',
    'Winners Quatre Bornes',
    'Winners Rose-Hill',
    'Winners Tribeca Central',
  ];

  double get _subtotal {
    return widget.cartItems.fold(
      0.0,
      (
        sum,
        item,
      ) =>
          sum +
          ((item['price']
                  as num) *
              (item['quantity']
                  as int)),
    );
  }

  double get _finalTotal {
    final double total =
        _subtotal -
        _discountAmount;
    return total <
            0
        ? 0.0
        : total;
  }

  int get _wiivPointsEarned => _finalTotal.floor();

  // --- VOUCHER VALIDATION LOGIC ---
  void _applyVoucherCode(
    String inputCode,
  ) {
    final code = inputCode.trim().toUpperCase();

    if (code.isEmpty) {
      _removeVoucher();
      return;
    }

    setState(
      () {
        if (code ==
            'RS100OFF') {
          if (_subtotal >=
              1000) {
            _discountAmount = 100.0;
            _appliedVoucherCode = code;
          } else {
            _showSnackBar(
              'Minimum purchase of Rs 1,000 required for RS100OFF',
              Colors.orange,
            );
            _removeVoucher();
            return;
          }
        } else if (code ==
            'FRESH20') {
          _discountAmount =
              _subtotal *
              0.20; // 20% Discount
          _appliedVoucherCode = code;
        } else if (code ==
            'WIIV50') {
          _discountAmount = 50.0;
          _appliedVoucherCode = code;
        } else {
          _showSnackBar(
            'Invalid or expired voucher code',
            Colors.red,
          );
          _removeVoucher();
          return;
        }
      },
    );

    _showSnackBar(
      'Voucher "$_appliedVoucherCode" applied successfully!',
      const Color(
        0xFF008751,
      ),
    );
  }

  void _removeVoucher() {
    setState(
      () {
        _discountAmount = 0.0;
        _appliedVoucherCode = null;
        _voucherController.clear();
      },
    );
  }

  void _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(
      Clipboard.kTextPlain,
    );
    if (data !=
            null &&
        data.text !=
            null) {
      _voucherController.text = data.text!;
      _applyVoucherCode(
        data.text!,
      );
    }
  }

  void _showSnackBar(
    String message,
    Color bgColor,
  ) {
    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor: bgColor,
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  void _placeOrder() async {
    if (widget.cartItems.isEmpty) return;

    final double finalAmount = _finalTotal;
    final int finalPoints = _wiivPointsEarned;

    setState(
      () => _isProcessing = true,
    );

    try {
      final userId = widget.userProfile['id'];

      // Create order in Supabase with voucher info
      await _supabase
          .from(
            'orders',
          )
          .insert(
            {
              'user_id': userId,
              'total_amount': finalAmount,
              'discount_applied': _discountAmount,
              'voucher_code': _appliedVoucherCode,
              'wiiv_points_earned': finalPoints,
              'fulfillment_type': _fulfillmentType,
              'pickup_store':
                  _fulfillmentType ==
                      'Click & Collect'
                  ? _selectedStore
                  : 'Home Address',
              'status': 'Completed',
            },
          );

      // Update Wiiv Points safely
      final currentPoints =
          widget.userProfile['wiiv_points'] ??
          0;
      final int newTotalPoints =
          currentPoints +
          finalPoints;

      await _supabase
          .from(
            'profiles',
          )
          .update(
            {
              'wiiv_points': newTotalPoints,
            },
          )
          .eq(
            'id',
            userId,
          );

      // Keep local profile map updated so callbacks see the change immediately
      widget.userProfile['wiiv_points'] = newTotalPoints;

      // Update Stock
      for (var item in widget.cartItems) {
        final currentStock =
            item['stock_quantity']
                as int;
        final qtyBought =
            item['quantity']
                as int;
        final newStock =
            currentStock -
            qtyBought;

        await _supabase
            .from(
              'products',
            )
            .update(
              {
                'stock_quantity':
                    newStock <
                        0
                    ? 0
                    : newStock,
              },
            )
            .eq(
              'id',
              item['id'],
            );
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (
              _,
            ) => AlertDialog(
              title: const Text(
                '🎉 Order Confirmed!',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subtotal: Rs ${_subtotal.toStringAsFixed(2)}',
                  ),
                  if (_discountAmount >
                      0)
                    Text(
                      'Discount ($_appliedVoucherCode): -Rs ${_discountAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(
                          0xFF008751,
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Total Paid: Rs ${finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    '🎁 You Earned: +$finalPoints Wiiv Points!',
                    style: const TextStyle(
                      color: Color(
                        0xFF008751,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Fulfillment: $_fulfillmentType${_fulfillmentType == 'Click & Collect' ? ' ($_selectedStore)' : ''}',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    widget.onOrderCompleted();
                    Navigator.pop(
                      context,
                    );
                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    'OK',
                  ),
                ),
              ],
            ),
      );
    } catch (
      e
    ) {
      if (mounted) {
        _showSnackBar(
          'Order processing failed: $e',
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(
          () => _isProcessing = false,
        );
      }
    }
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
          'My Supermarket Cart',
        ),
        backgroundColor: winnersGreen,
        foregroundColor: Colors.white,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your basket is empty.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final item = widget.cartItems[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                6,
                              ),
                              child: Image.network(
                                item['image_url'] ??
                                    '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (
                                      _,
                                      __,
                                      ___,
                                    ) => const Icon(
                                      Icons.shopping_bag,
                                      color: winnersGreen,
                                      size: 30,
                                    ),
                              ),
                            ),
                            title: Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Rs ${item['price']} x ${item['quantity']}',
                            ),
                            trailing: Text(
                              'Rs ${((item['price'] as num) * (item['quantity'] as int)).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // --- VOUCHER INPUT FIELD ---
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _voucherController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Enter Voucher / Promo Code',
                                isDense: true,
                                border: const OutlineInputBorder(),
                                suffixIcon:
                                    _appliedVoucherCode !=
                                        null
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: _removeVoucher,
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.paste_rounded,
                                        ),
                                        tooltip: 'Paste Code',
                                        onPressed: _pasteFromClipboard,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: winnersGreen,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onPressed: () => _applyVoucherCode(
                              _voucherController.text,
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),

                      // --- FULFILLMENT METHOD ---
                      DropdownButtonFormField<
                        String
                      >(
                        value: _fulfillmentType,
                        decoration: const InputDecoration(
                          labelText: 'Fulfillment Method',
                        ),
                        items:
                            [
                                  'Click & Collect',
                                  'Home Delivery',
                                ]
                                .map(
                                  (
                                    e,
                                  ) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (
                              val,
                            ) => setState(
                              () => _fulfillmentType = val!,
                            ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),

                      if (_fulfillmentType ==
                          'Click & Collect')
                        DropdownButtonFormField<
                          String
                        >(
                          value: _selectedStore,
                          decoration: const InputDecoration(
                            labelText: 'Pickup Supermarket Branch',
                          ),
                          items: _winnersStores
                              .map(
                                (
                                  e,
                                ) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged:
                              (
                                val,
                              ) => setState(
                                () => _selectedStore = val!,
                              ),
                        ),

                      const Divider(
                        height: 20,
                      ),

                      // --- SUMMARY CALCULATIONS ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal:',
                          ),
                          Text(
                            'Rs ${_subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_discountAmount >
                          0) ...[
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount ($_appliedVoucherCode):',
                              style: const TextStyle(
                                color: winnersGreen,
                              ),
                            ),
                            Text(
                              '- Rs ${_discountAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: winnersGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rs ${_finalTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: winnersGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),

                      // --- PLACE ORDER BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: winnersGreen,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          onPressed: _isProcessing
                              ? null
                              : _placeOrder,
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'PLACE ORDER (+ $_wiivPointsEarned WIIV PTS)',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
