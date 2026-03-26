import 'package:flutter/material.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  final List<String> markets = const ['දඹුල්ල', 'පැල්ල', 'මීගොඩ'];
  final List<Map<String, dynamic>> vegetables = const [
    {'name': 'වම්බටු', 'price': 120},
    {'name': 'මිරිස්', 'price': 350},
    {'name': 'විවිටක්කා', 'price': 150},
    {'name': 'කැරට්', 'price': 180},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('මිල ගණන්'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'එළවළුවක් සොයන්න...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          // Market tabs
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: markets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(markets[index]),
                    selected: index == 0, // Just for demo
                    onSelected: (selected) {},
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Price list
          Expanded(
            child: ListView.builder(
              itemCount: vegetables.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[100],
                      child: Text(
                        vegetables[index]['name'][0],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(vegetables[index]['name']),
                    trailing: Text(
                      'රු. ${vegetables[index]['price']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
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