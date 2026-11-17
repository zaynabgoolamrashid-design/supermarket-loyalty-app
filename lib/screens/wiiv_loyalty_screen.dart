import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class WiivLoyaltyScreen
    extends
        StatelessWidget {
  final Map<
    String,
    dynamic
  >
  userProfile;

  const WiivLoyaltyScreen({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const winnersGreen = Color(
      0xFF008751,
    );
    final String wiivCardNo =
        userProfile['wiiv_card_number']?.toString() ??
        'WIIV-99882211';
    final String memberName =
        userProfile['full_name']?.toString() ??
        'Customer';
    final int points =
        (userProfile['wiiv_points']
                as num?)
            ?.toInt() ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wiiv Rewards Card',
        ),
        backgroundColor: winnersGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Constrains the maximum width so it stays credit-card sized on Desktop/Chrome
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                  ),
                  color: const Color(
                    0xFFD32F2F,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'wiiv',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Icon(
                              Icons.nfc,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Text(
                          'Member: $memberName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Card No: $wiivCardNo',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                '$points Wiiv Points',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 36,
              ),
              const Text(
                'Scan Barcode at Checkout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              BarcodeWidget(
                barcode: Barcode.code128(),
                data: wiivCardNo,
                width: 260,
                height: 85,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
