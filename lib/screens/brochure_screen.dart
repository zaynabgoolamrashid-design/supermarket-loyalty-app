import 'package:flutter/material.dart';
import '../supabase_config.dart';

class BrochureScreen
    extends
        StatefulWidget {
  const BrochureScreen({
    super.key,
  });

  @override
  State<
    BrochureScreen
  >
  createState() => _BrochureScreenState();
}

class _BrochureScreenState
    extends
        State<
          BrochureScreen
        > {
  final PageController _pageController = PageController();
  final _supabase = SupabaseConfig.client;

  int _currentPage = 0;
  bool _isGridView = false;
  String _searchFilter = '';

  @override
  Widget build(
    BuildContext context,
  ) {
    const winnersGreen = Color(
      0xFF008751,
    );
    const topBarColor = Color(
      0xFF4A3E3D,
    );
    const bottomBarColor = Color(
      0xFFD9D0C7,
    );

    return Scaffold(
      backgroundColor: bottomBarColor,
      body: SafeArea(
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
                          'Error: ${snapshot.error}',
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: winnersGreen,
                        ),
                      );
                    }

                    final allProducts = snapshot.data!;

                    final products = _searchFilter.isEmpty
                        ? allProducts
                        : allProducts
                              .where(
                                (
                                  p,
                                ) => p['name'].toString().toLowerCase().contains(
                                  _searchFilter.toLowerCase(),
                                ),
                              )
                              .toList();

                    final coverProducts = products
                        .take(
                          4,
                        )
                        .toList();
                    final page1Products = products
                        .skip(
                          0,
                        )
                        .take(
                          6,
                        )
                        .toList();
                    final page2Products = products
                        .skip(
                          6,
                        )
                        .take(
                          6,
                        )
                        .toList();

                    final List<
                      Widget
                    >
                    brochurePages = [
                      _buildCoverPage(
                        coverProducts,
                      ),
                      _buildProductCatalogPage(
                        'LA FOIRE BEL BEL CADDIE',
                        'DU 24 JUILLET AU 6 AOÛT 2026',
                        page1Products,
                        const Color(
                          0xFFE65100,
                        ),
                      ),
                      _buildProductCatalogPage(
                        'ÉPICERIE & PRODUITS FRAIS',
                        'DU 24 JUILLET AU 6 AOÛT 2026',
                        page2Products,
                        const Color(
                          0xFFC2185B,
                        ),
                      ),
                    ];

                    return Column(
                      children: [
                        // --- TOP TOOLBAR ---
                        Container(
                          color: topBarColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                tooltip: 'Back',
                                onPressed: () => Navigator.pop(
                                  context,
                                ),
                              ),
                              const Text(
                                'Winners Brochure',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              // Wrapped extra buttons into a PopupMenuButton to avoid horizontal overflow
                              PopupMenuButton<
                                String
                              >(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                                tooltip: 'Options',
                                onSelected:
                                    (
                                      value,
                                    ) {
                                      if (value ==
                                          'search') {
                                        _showSearchDialog(
                                          context,
                                        );
                                      } else if (value ==
                                          'overview') {
                                        setState(
                                          () => _isGridView = !_isGridView,
                                        );
                                      } else if (value ==
                                          'download') {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Downloading Brochure PDF...',
                                            ),
                                            backgroundColor: winnersGreen,
                                          ),
                                        );
                                      } else if (value ==
                                          'share') {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Brochure link copied!',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                itemBuilder:
                                    (
                                      BuildContext context,
                                    ) => [
                                      const PopupMenuItem<
                                        String
                                      >(
                                        value: 'search',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.search,
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              'Search',
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<
                                        String
                                      >(
                                        value: 'overview',
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.grid_view_rounded,
                                              size: 18,
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              _isGridView
                                                  ? 'Exit Overview'
                                                  : 'Overview',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<
                                        String
                                      >(
                                        value: 'download',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.picture_as_pdf,
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              'Download PDF',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<
                                        String
                                      >(
                                        value: 'share',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.share,
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              'Share',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                        ),

                        // --- MAIN BROCHURE CONTENT ---
                        Expanded(
                          child: _isGridView
                              ? _buildOverviewGrid(
                                  brochurePages.length,
                                )
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PageView.builder(
                                      controller: _pageController,
                                      onPageChanged:
                                          (
                                            index,
                                          ) => setState(
                                            () => _currentPage = index,
                                          ),
                                      itemCount: brochurePages.length,
                                      itemBuilder:
                                          (
                                            context,
                                            index,
                                          ) {
                                            return InteractiveViewer(
                                              maxScale: 3.0,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12.0,
                                                ),
                                                child: brochurePages[index],
                                              ),
                                            );
                                          },
                                    ),
                                    if (_currentPage >
                                        0)
                                      Positioned(
                                        left: 12,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black87,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.chevron_left,
                                              color: Colors.white,
                                            ),
                                            onPressed: () => _pageController.previousPage(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeInOut,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_currentPage <
                                        brochurePages.length -
                                            1)
                                      Positioned(
                                        right: 12,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black87,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                            ),
                                            onPressed: () => _pageController.nextPage(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeInOut,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),

                        // --- BOTTOM NAVIGATION CONTROLS ---
                        Container(
                          color: const Color(
                            0xFFC8BFB5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.first_page,
                                ),
                                onPressed:
                                    _currentPage >
                                        0
                                    ? () => _pageController.jumpToPage(
                                        0,
                                      )
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.chevron_left,
                                ),
                                onPressed:
                                    _currentPage >
                                        0
                                    ? () => _pageController.previousPage(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeInOut,
                                      )
                                    : null,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    4,
                                  ),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Text(
                                  '${_currentPage + 1} / ${brochurePages.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.chevron_right,
                                ),
                                onPressed:
                                    _currentPage <
                                        brochurePages.length -
                                            1
                                    ? () => _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeInOut,
                                      )
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.last_page,
                                ),
                                onPressed:
                                    _currentPage <
                                        brochurePages.length -
                                            1
                                    ? () => _pageController.jumpToPage(
                                        brochurePages.length -
                                            1,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
            ),
      ),
    );
  }

  // Cover Page
  Widget _buildCoverPage(
    List<
      Map<
        String,
        dynamic
      >
    >
    featuredItems,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFFFFD600,
        ),
        borderRadius: BorderRadius.circular(
          12,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            color: const Color(
              0xFF003882,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.shopping_basket,
                  color: Colors.white,
                  size: 26,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'WINNERS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(
                12,
              ),
              padding: const EdgeInsets.all(
                12,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE91E63,
                ),
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFFEB3B,
                      ),
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                    ),
                    child: const Text(
                      'BEL BEL CADDIE',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(
                          0xFF003882,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  const Text(
                    'SPECIAL OFFERS IN STORE & ONLINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: featuredItems.length,
                      itemBuilder:
                          (
                            context,
                            i,
                          ) => _buildProductTile(
                            featuredItems[i],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              bottom: 8.0,
            ),
            child: Text(
              'DU 24 JUILLET AU 6 AOÛT 2026',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Catalog Page Layout
  Widget _buildProductCatalogPage(
    String headerTitle,
    String dateRange,
    List<
      Map<
        String,
        dynamic
      >
    >
    items,
    Color headerColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFFFFFDE7,
        ),
        borderRadius: BorderRadius.circular(
          12,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            color: headerColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  headerTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  dateRange,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(
                10.0,
              ),
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'No products available for this page.',
                      ),
                    )
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: items.length,
                      itemBuilder:
                          (
                            context,
                            idx,
                          ) => _buildProductTile(
                            items[idx],
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Individual Product Tile with automatic image fallback
  Widget _buildProductTile(
    Map<
      String,
      dynamic
    >
    item,
  ) {
    final String? rawUrl = item['image_url'];
    final bool isAntiGasp =
        item['is_anti_gaspillage'] ??
        false;
    final dynamic price =
        item['price'] ??
        0;
    final String name =
        item['name'] ??
        'Product Item';

    const String defaultFallbackImage = 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&q=80';

    final String displayUrl =
        (rawUrl !=
                null &&
            rawUrl.trim().isNotEmpty)
        ? rawUrl.trim()
        : defaultFallbackImage;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          8,
        ),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
          ),
        ],
      ),
      padding: const EdgeInsets.all(
        6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Region
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                4,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      displayUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Image.network(
                              defaultFallbackImage,
                              fit: BoxFit.cover,
                            );
                          },
                    ),
                  ),
                  if (isAntiGasp)
                    Positioned(
                      top: 2,
                      left: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(
                            3,
                          ),
                        ),
                        child: const Text(
                          'ANTI-GASP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),

          // Product Name Title
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              height: 1.1,
            ),
          ),
          const SizedBox(
            height: 4,
          ),

          // Price Tag Container
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFD600,
              ),
              borderRadius: BorderRadius.circular(
                4,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rs',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$price',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Color(
                      0xFFD50000,
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

  // Overview Page Grid
  Widget _buildOverviewGrid(
    int totalPages,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(
        16,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: totalPages,
      itemBuilder:
          (
            context,
            index,
          ) {
            return GestureDetector(
              onTap: () {
                setState(
                  () => _isGridView = false,
                );
                _pageController.jumpToPage(
                  index,
                );
              },
              child: Card(
                elevation: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 36,
                      color: Color(
                        0xFF008751,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Page ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  // Search Dialog
  void _showSearchDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder:
          (
            ctx,
          ) {
            String tempQuery = _searchFilter;
            return AlertDialog(
              title: const Text(
                'Search Brochure',
              ),
              content: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search product name...',
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                ),
                onChanged:
                    (
                      val,
                    ) => tempQuery = val,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(
                      () => _searchFilter = '',
                    );
                    Navigator.pop(
                      ctx,
                    );
                  },
                  child: const Text(
                    'Clear',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(
                      () => _searchFilter = tempQuery,
                    );
                    Navigator.pop(
                      ctx,
                    );
                  },
                  child: const Text(
                    'Search',
                  ),
                ),
              ],
            );
          },
    );
  }
}
