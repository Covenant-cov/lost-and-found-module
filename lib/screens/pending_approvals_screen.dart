import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingApprovalsScreen extends StatelessWidget {
  static String id = 'pending_approvals_screen';

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(ctx),
              ),
              TextButton(
                child: Text('Confirm', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.pop(ctx);
                  onConfirm();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Approvals', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4B3F72),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pending_found_items')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error fetching items.'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          final items = snapshot.data!.docs;

          if (items.isEmpty) return Center(child: Text('No pending items.'));

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final data = items[index].data() as Map<String, dynamic>;
              final docId = items[index].id;

              return Card(
                margin: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['imageUrl'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            data['imageUrl'],
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 10),
                      Text(
                        data['itemName'] ?? 'Unnamed Item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text('Category: ${data['category'] ?? 'N/A'}'),
                      Text('Location: ${data['location'] ?? 'Unknown'}'),
                      Text('Reported By: ${data['email'] ?? 'N/A'}'),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: Icon(Icons.check, color: Colors.green),
                            label: Text(
                              'Approve',
                              style: TextStyle(color: Colors.green),
                            ),
                            onPressed: () {
                              _showConfirmationDialog(
                                context: context,
                                title: 'Approve Item',
                                message:
                                    'Are you sure you want to approve this item?',
                                onConfirm: () async {
                                  await FirebaseFirestore.instance
                                      .collection('found_items')
                                      .add(data);
                                  await FirebaseFirestore.instance
                                      .collection('pending_found_items')
                                      .doc(docId)
                                      .delete();
                                },
                              );
                            },
                          ),
                          SizedBox(width: 8),
                          TextButton.icon(
                            icon: Icon(Icons.close, color: Colors.red),
                            label: Text(
                              'Reject',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              _showConfirmationDialog(
                                context: context,
                                title: 'Reject Item',
                                message:
                                    'Are you sure you want to reject and delete this item?',
                                onConfirm: () async {
                                  await FirebaseFirestore.instance
                                      .collection('pending_found_items')
                                      .doc(docId)
                                      .delete();
                                },
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
    );
  }
}
