import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  static String id = 'notifications_screen';

  final Color purple = Color(0xFF4B3F72);

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: userId)
                // .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return Center(child: Text('No notifications.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Notification';
              final message = data['message'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final formattedDate =
                  timestamp != null
                      ? DateFormat('d/M/yyyy HH:mm').format(timestamp.toDate())
                      : '';

              return GestureDetector(
                onTap: () async {
                  if (!(data['read'] ?? false)) {
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(notifications[index].id)
                        .update({'read': true});
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        (data['read'] ?? false)
                            ? purple.withOpacity(0.5) // lighter if read
                            : purple.withOpacity(0.9), // darker if unread
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications,
                        color:
                            (data['read'] ?? false)
                                ? Colors.white54
                                : Colors.white,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              message,
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: 6),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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
