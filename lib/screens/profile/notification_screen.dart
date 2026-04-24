import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // 🔥 Background එක theme එක අනුව මාරු වේ
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // 🔥 AppBar එකත් theme එකට අනුව මාරු වේ
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong", style: TextStyle(color: theme.colorScheme.onSurface)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: isDark ? Colors.white24 : Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("No notifications yet", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var note = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              DateTime displayDate;
              try {
                if (note['timestamp'] != null && note['timestamp'] is Timestamp) {
                  displayDate = (note['timestamp'] as Timestamp).toDate();
                } else {
                  displayDate = DateTime.now();
                }
              } catch (e) {
                displayDate = DateTime.now();
              }

              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 6),
                // 🔥 Card එකේ පසුබිම theme එක අනුව මාරු වේ (Gemini Dark Grey)
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: isDark ? Colors.white10 : Colors.grey[100]!, width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: note['type'] == 'alert'
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    child: Icon(
                      note['type'] == 'alert' ? Icons.warning_amber_rounded : Icons.info_outline,
                      color: note['type'] == 'alert' ? Colors.orange : Colors.green[700],
                    ),
                  ),
                  title: Text(
                    note['title'] ?? "New Notification",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface // 🔥 Text Color Adaptive
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        note['message'] ?? "No message content available.",
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('yyyy-MM-dd | hh:mm a').format(displayDate),
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}