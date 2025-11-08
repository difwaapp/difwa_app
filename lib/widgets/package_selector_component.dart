import 'package:difwa_app/config/app_constant.dart';
import 'package:flutter/material.dart';

class PackageSelectorComponent extends StatefulWidget {
  final List<Map<String, dynamic>> bottleItems;
  final Function(Map<String, dynamic>?) onSelected;

  const PackageSelectorComponent({
    super.key,
    required this.bottleItems,
    required this.onSelected,
  });

  @override
  State<PackageSelectorComponent> createState() =>
      _PackageSelectorComponentState();
}

class _PackageSelectorComponentState extends State<PackageSelectorComponent> {
  int _selectedIndex = -1;

  void _handleSelection(int index) {
    var entry = widget.bottleItems[index];
    bool isActive = entry['isActive'] ?? true;

    if (!isActive) {
      debugPrint("🚫 Merchant is inactive: ${entry['vendorName']}");
      return;
    }

    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = -1;
        widget.onSelected(null);
      } else {
        _selectedIndex = index;
        widget.onSelected(entry);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint("🔍 [DEBUG] Entered PackageSelectorComponent");
    debugPrint(
        "📦 [DEBUG] Bottle items received (${widget.bottleItems.length} items):");
    for (var i = 0; i < widget.bottleItems.length; i++) {
      debugPrint("   ➤ Bottle ${i + 1}: ${widget.bottleItems[i]}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          const Text(
            'Select Your Package',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.bottleItems.length,
              itemBuilder: (context, index) {
                var entry = widget.bottleItems[index];
                var bottle = entry['itemData'] ?? {};

                bool isSelected = index == _selectedIndex;
                bool isActive = entry['isActive'] ?? true;

                String imageUrl =
                    bottle['imageUrl'] ?? bottleImageUrl; // Fallback image URL
                String merchantName =
                    entry['vendorName'] ?? 'Vendor'; // Use entry['vendorName']
                String size =
                    bottle['size']?.toString() ?? ''; // Default empty string
                String name = bottle['name'] ?? 'Premium'; // Default 'Premium'
                double price = (bottle['price'] ?? 0)
                    .toDouble(); // Ensure price is a double

                return GestureDetector(
                  onTap: () => _handleSelection(index),
                  child: Opacity(
                    opacity: isActive ? 1.0 : 0.4,
                    child: Container(
                      width: 174,
                      margin: EdgeInsets.only(
                        right: index == widget.bottleItems.length - 1 ? 0 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.grey,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$size L $name',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              merchantName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              isActive ? "Active" : "Inactive",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
