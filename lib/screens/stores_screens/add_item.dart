import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/utils/app__text_style.dart';
import 'package:difwa_app/utils/theme_constant.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AddItem> {
  final List<Map<String, dynamic>> bottleSizes = [
    {
      'size': 10,
      'price': 10.0,
      'image': 'https://5.imimg.com/data5/RK/MM/MY-26385841/ff-1000x1000.jpg'
    },
    {
      'size': 15,
      'price': 20.0,
      'image': 'https://5.imimg.com/data5/RK/MM/MY-26385841/ff-1000x1000.jpg'
    },
    {
      'size': 18,
      'price': 25.0,
      'image': 'https://5.imimg.com/data5/RK/MM/MY-26385841/ff-1000x1000.jpg'
    },
    {
      'size': 20,
      'price': 30.0,
      'image': 'https://5.imimg.com/data5/RK/MM/MY-26385841/ff-1000x1000.jpg'
    },
  ];

  int? selectedBottleSize;
  double vacantBottlePrice = 0.0;
  final FirebaseController _controller = FirebaseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.whiteColor,
      appBar: AppBar(
        title: Text(
          'Select Waters',
          style:
              AppTextStyle.Text18600.copyWith(color: ThemeConstants.whiteColor),
        ),
        backgroundColor: ThemeConstants.blackColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Select a Bottle to Sell",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: bottleSizes.length,
                itemBuilder: (context, index) {
                  final bottle = bottleSizes[index];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBottleSize = bottle['size'];
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 4,
                      color: selectedBottleSize == bottle['size']
                          ? Colors.blue.shade100
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              bottle['image'],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${bottle['size']}L',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹ ${bottle['price']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedBottleSize != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      'Selected Bottle: $selectedBottleSize L',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          vacantBottlePrice = double.tryParse(value) ?? 0.0;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Vacant Bottle Price (₹)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '₹ 0.0',
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: "Add",
                      onPressed: () async {
                        if (vacantBottlePrice > 0) {
                          try {
                            print("Bottlewsdz");

                            await _controller.addBottleData(
                              selectedBottleSize!,
                              bottleSizes.firstWhere((b) =>
                                  b['size'] == selectedBottleSize!)['price'],
                              vacantBottlePrice,
                            );
                            print("Bottle added successfully");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bottle added successfully')),
                            );

                            // Reset form state
                            setState(() {
                              selectedBottleSize =
                                  null; // Clear selected bottle size
                              vacantBottlePrice =
                                  0.0; // Reset vacant bottle price
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Errtfdor: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please select a bottle size and price')),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
