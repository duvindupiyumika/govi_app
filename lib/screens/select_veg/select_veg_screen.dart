import 'package:flutter/material.dart';

class SelectVegScreen extends StatelessWidget {
  const SelectVegScreen({super.key});

  final List<String> vegetables = const [
    'වම්බටු',
    'මිරිස්',
    'විවිටක්කා',
    'කැරට්',
    'ගෝවා',
    'බෝංචි',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('වගා යෝජනා'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location input
            TextField(
              decoration: InputDecoration(
                labelText: 'ප්‍රදේශය',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // Date input
            TextField(
              decoration: InputDecoration(
                labelText: 'වගා කරන දිනය',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),

            // Land size
            TextField(
              decoration: InputDecoration(
                labelText: 'බිම් ප්‍රමාණය (අක්කර)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.square_foot),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Vegetable selection
            const Text(
              'එළවළු තෝරන්න:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...vegetables.map((veg) => CheckboxListTile(
              title: Text(veg),
              value: false,
              onChanged: (value) {},
            )),

            const SizedBox(height: 20),

            // Analyze button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Show analysis result
                  _showAnalysisDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'විශ්ලේෂණය',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalysisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI යෝජනාව'),
        content: const Text(
          'ඔබේ ප්‍රදේශයට වම්බටු වගා කිරීම වඩාත් සුදුසුයි.\n\n'
              'අනුරාධපුරට කැරට් සුදුසු නැහැ.\n\n'
              'අප්‍රේල් 25 වෙනිදා විවිටක්කා හිඟයක් ඇතිවිය හැකි නිසා විවිටක්කා වගා කිරීමෙන් වැඩි ලාභයක් ලබාගත හැක.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('හරි'),
          ),
        ],
      ),
    );
  }
}