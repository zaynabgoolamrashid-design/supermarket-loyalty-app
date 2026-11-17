import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Voucher {
  final String id;
  final String title;
  final String description;
  final String validUntil;
  final String code;
  final Color themeColor;

  Voucher({
    required this.id,
    required this.title,
    required this.description,
    required this.validUntil,
    required this.code,
    required this.themeColor,
  });
}

class VouchersScreen
    extends
        StatefulWidget {
  const VouchersScreen({
    super.key,
  });

  @override
  State<
    VouchersScreen
  >
  createState() => _VouchersScreenState();
}

class _VouchersScreenState
    extends
        State<
          VouchersScreen
        > {
  // Sample voucher list
  final List<
    Voucher
  >
  vouchers = [
    Voucher(
      id: '1',
      title: 'Rs 100 OFF',
      description: 'On minimum purchase of Rs 1,000 across all store categories.',
      validUntil: '31 Aug 2026',
      code: 'RS100OFF',
      themeColor: Colors.purple,
    ),
    Voucher(
      id: '2',
      title: '20% OFF',
      description: 'Save on fresh fruits, vegetables, and daily farm products.',
      validUntil: '15 Aug 2026',
      code: 'FRESH20',
      themeColor: Colors.green,
    ),
    Voucher(
      id: '3',
      title: 'Rs 50 OFF',
      description: 'Exclusive reward discount for Wiiv Loyalty card members.',
      validUntil: '31 Dec 2026',
      code: 'WIIV50',
      themeColor: Colors.orange,
    ),
  ];

  String? _selectedVoucherCode;

  void _applyVoucher(
    Voucher voucher,
  ) {
    setState(
      () {
        _selectedVoucherCode = voucher.code;
      },
    );

    // Copy coupon code to clipboard
    Clipboard.setData(
      ClipboardData(
        text: voucher.code,
      ),
    );

    // Display confirmation SnackBar at the bottom
    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Voucher code "${voucher.code}" copied & applied!',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(
          0xFF008751,
        ),
        duration: const Duration(
          seconds: 3,
        ),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    const primaryGreen = Color(
      0xFF008751,
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F5F5,
      ),
      appBar: AppBar(
        title: const Text(
          'My Vouchers & Offers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          // Fixed: using BoxConstraints for max width constraint
          constraints: const BoxConstraints(
            maxWidth: 650,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          child: ListView.separated(
            itemCount: vouchers.length,
            separatorBuilder:
                (
                  context,
                  index,
                ) => const SizedBox(
                  height: 16,
                ),
            itemBuilder:
                (
                  context,
                  index,
                ) {
                  final voucher = vouchers[index];
                  final isApplied =
                      _selectedVoucherCode ==
                      voucher.code;

                  return Card(
                    elevation: 2,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16.0,
                      ),
                      child: Row(
                        children: [
                          // Circular Icon Avatar
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: voucher.themeColor.withOpacity(
                              0.15,
                            ),
                            child: Icon(
                              Icons.confirmation_number,
                              color: voucher.themeColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),

                          // Text Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  voucher.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: voucher.themeColor,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  voucher.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  'Valid until ${voucher.validUntil}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),

                          // Apply Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isApplied
                                  ? Colors.grey
                                  : primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => _applyVoucher(
                              voucher,
                            ),
                            child: Text(
                              isApplied
                                  ? 'Applied'
                                  : 'Apply',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
          ),
        ),
      ),
    );
  }
}
