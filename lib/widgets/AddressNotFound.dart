import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/screens/auth/adddress_form_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddressNotFound extends StatelessWidget {
  const AddressNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'No Address Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'You have not added any address yet. Please add a new address to proceed.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressForm(
                      address: Address(
                          docId: "",
                          name: "",
                          street: "",
                          city: "",
                          state: "",
                          zip: "",
                          isDeleted: false,
                          isSelected: false,
                          country: "",
                          phone: "",
                          saveAddress: false,
                          uid: "",
                          floor: "",
                          locationType: ''),
                      flag: "",
                    ),
                  ),
                );
              },
              icon: const Icon(
                FontAwesomeIcons.plus,
                color: Colors.white,
              ),
              label: const Text('Add New Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
