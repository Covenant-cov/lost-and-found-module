import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatefulWidget {
  static String id = 'favorites_screen';

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('My Claims'),
        backgroundColor: Color(0xFF643579),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedStatus,
              items:
                  ['All', 'Pending', 'Approved', 'Resolved']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
              isExpanded: true,
            ),
          ),

          // Claims List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final items = snapshot.data!.docs;

                if (items.isEmpty) {
                  return Center(child: Text('No items found.'));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Icon(
                        Icons.inventory_2,
                        color: Color(0xFF643579),
                      ),
                      title: Text(item['itemName'] ?? 'Unnamed Item'),
                      subtitle: Text(item['description'] ?? ''),
                      trailing: _buildStatusChip(item['status']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Fetch filtered stream based on selected status
  Stream<QuerySnapshot> _getFilteredStream(String userId) {
    if (selectedStatus == 'All') {
      return FirebaseFirestore.instance
          .collection('claimed_items')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('claimed_items')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('status', isEqualTo: selectedStatus.toLowerCase())
          .snapshots();
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.yellow.shade700;
        break;
      case 'approved':
        color = Colors.blue;
        break;
      case 'resolved':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status[0].toUpperCase() + status.substring(1)),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}
