import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAQ Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FAQPage(),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of FAQ items
    final List<Map<String, String>> faqs = [
      {
        'question': 'Is Difwa Packaged drinking Water safe to drink?',
        'answer':
            'Difwa Packaged Drinking Water is generally safe to drink if it meets quality standards and is properly sealed. Always check for certification marks like ISI and ensure the packaging is intact.'
      },
      {
        'question': 'Is mineral water good for health?',
        'answer':
            'Mineral water can be beneficial as it contains essential minerals. However, excessive consumption may lead to health issues due to high mineral content.'
      },
      {
        'question': 'The TDS level of Difwa Packaged drinking water?',
        'answer':
            'The TDS (Total Dissolved Solids) level of Difwa Packaged Drinking Water is typically below 500 mg/L, which is considered safe for drinking.'
      },
      {
        'question': 'Can I schedule a delivery for a specific time?',
        'answer':
            'Yes, you can schedule a delivery for a specific time when placing your order through the Difwa app.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: ListView(
        children: faqs.map((faq) {
          return ExpansionTile(
            title: Container(
              decoration: BoxDecoration(
                color: appTheme.primaryColor.withOpacity(
                    0.1), // Background color with opacity for question
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                faq['question']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(
                      0.5), // Background color with opacity for answer
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(faq['answer']!),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
