import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethods extends StatefulWidget {
  const PaymentMethods({super.key});

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addPaymentMethod(String type) async {
    TextEditingController accountNumberController = TextEditingController();
    TextEditingController ifscController = TextEditingController();
    TextEditingController branchController = TextEditingController();
    TextEditingController accountNameController = TextEditingController();
    TextEditingController upiController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter $type Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              if (type == "Bank Account") ...[
                TextField(
                  controller: accountNameController,
                  decoration: InputDecoration(
                      hintText: "Account Holder Name",
                      border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: accountNumberController,
                  decoration: InputDecoration(
                      hintText: "Account Number", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: ifscController,
                  decoration: InputDecoration(
                      hintText: "IFSC Code", border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: branchController,
                  decoration: InputDecoration(
                      hintText: "Branch Name", border: OutlineInputBorder()),
                ),
              ] else ...[
                TextField(
                  controller: upiController,
                  decoration: InputDecoration(
                      hintText: "Enter UPI ID", border: OutlineInputBorder()),
                ),
              ],
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if ((type == "Bank Account" &&
                          accountNumberController.text.isNotEmpty &&
                          ifscController.text.isNotEmpty &&
                          branchController.text.isNotEmpty &&
                          accountNameController.text.isNotEmpty) ||
                      (type == "UPI ID" && upiController.text.isNotEmpty)) {
                    await _firestore
                        .collection("users")
                        .doc("currentUser")
                        .collection("paymentMethods")
                        .add({
                      "type": type,
                      "accountName": accountNameController.text,
                      "accountNumber": accountNumberController.text,
                      "ifsc": ifscController.text,
                      "branch": branchController.text,
                      "upi": upiController.text,
                    });
                    Navigator.pop(context);
                    setState(() {});
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPaymentMethods() async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .doc("currentUser")
        .collection("paymentMethods")
        .get();
    return snapshot.docs
        .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> _deletePaymentMethod(String id) async {
    await _firestore
        .collection("users")
        .doc("currentUser")
        .collection("paymentMethods")
        .doc(id)
        .delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Methods")),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _fetchPaymentMethods(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Payment Methods Added"));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var paymentMethod = snapshot.data![index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Colors.white,
                child: ListTile(
                  leading: Icon(paymentMethod["type"] == "Bank Account"
                      ? Icons.account_balance
                      : Icons.payment),
                  title: Text(paymentMethod["type"] ?? "Unknown"),
                  subtitle: Text(paymentMethod["type"] == "Bank Account"
                      ? "${paymentMethod["accountName"]} - ${paymentMethod["accountNumber"]}\n${paymentMethod["ifsc"]}, ${paymentMethod["branch"]}"
                      : paymentMethod["upi"] ?? "No details"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePaymentMethod(paymentMethod["id"]!),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: Colors.white,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.account_balance),
                      title: Text("Bank Account"),
                      onTap: () {
                        Navigator.pop(context);
                        _addPaymentMethod("Bank Account");
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.payment),
                      title: Text("UPI ID"),
                      onTap: () {
                        Navigator.pop(context);
                        _addPaymentMethod("UPI ID");
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
