import 'package:flutter/material.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  final List<Map<String, dynamic>> alerts = const [
    {
      'title': 'leaf curl රෝගය',
      'description': 'මිරිස් වලට මෙම රෝගය ඇතිවිය හැක. කොළ ඇඹරීම, කොළ කහ වීම වැනි රෝග ලක්ෂණ.',
      'date': 'මාර්තු 15',
    },
    {
      'title': 'NPK පොහොර යෙදීම',
      'description': 'වම්බටු වලට NPK 12:12:17 පොහොර යෙදීමට සුදුසුම කාලය.',
      'date': 'මාර්තු 20',
    },
    {
      'title': 'කොළ පුළුන් කෘමියා',
      'description': 'කැරට් වලට මෙම කෘමියා හානි කළ හැක. වහාම පාලනය කරන්න.',
      'date': 'මාර්තු 18',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('දැනුම හා උපදෙස්'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          index == 0 ? Icons.warning : Icons.info,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          alert['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(alert['description']),
                  const SizedBox(height: 10),
                  Text(
                    'දිනය: ${alert['date']}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}