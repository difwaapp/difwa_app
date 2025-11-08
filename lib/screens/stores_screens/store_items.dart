import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/screens/stores_screens/add_item.dart';
import 'package:difwa_app/utils/theme_constant.dart';
import 'package:flutter/material.dart';

class StoreItems extends StatelessWidget {
  const StoreItems({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseController controller = FirebaseController();

    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Store Items',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeConstants.blackColor,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: controller.fetchBottleItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bottleItems = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bottleItems.length,
            itemBuilder: (context, index) {
              final item = bottleItems[index];

              String imagePath;
              if (item['size'] == 10) {
                imagePath = 'assets/images/water.jpg';
              } else if (item['size'] == 20) {
                imagePath = 'assets/images/water.jpg';
              } else {
                imagePath = 'assets/images/water.jpg';
              }

              return Card(
                color: ThemeConstants.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display image based on the size of the bottle
                      Image.asset(
                        imagePath, // Use the dynamically selected image path
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 16),
                      // Bottle Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['size']}L',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Price: ₹${item['price']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vacant Bottle Price: ₹${item['vacantPrice']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Edit and Delete buttons
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // IconButton(
                          //   icon: const Icon(Icons.edit),
                          //   onPressed: () {
                          //     // Handle edit
                          //   },
                          // ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await controller.deleteBottleData(item['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Item deleted')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddItem screen when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItem()),
          );
        },
        backgroundColor: ThemeConstants.blackColor,
        child: const Icon(
          Icons.add,
          color: ThemeConstants.whiteColor,
        ),
      ),
    );
  }
}
