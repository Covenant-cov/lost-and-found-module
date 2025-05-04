import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserReportedFoundScreen extends StatefulWidget {
  static String id = 'user_reported_found_screen';

  @override
  _UserReportedFoundScreenState createState() =>
      _UserReportedFoundScreenState();
}

class _UserReportedFoundScreenState extends State<UserReportedFoundScreen> {
  final CollectionReference foundItems = FirebaseFirestore.instance.collection(
    'found_items',
  );

  String _searchTerm = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'Electronics',
    'Clothing',
    'Books',
    'Accessories',
    'Other',
  ];

  void _showClaimDialog(BuildContext context, String itemId, String itemName) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final departmentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Claim Item'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Your Name (full)'),
                  ),
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(labelText: 'Your ID'),
                  ),
                  TextField(
                    controller: departmentController,
                    decoration: InputDecoration(labelText: 'Your Department'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final userId = idController.text.trim();
                  final department = departmentController.text.trim();

                  if (name.isNotEmpty &&
                      userId.isNotEmpty &&
                      department.isNotEmpty) {
                    // Save the claim request in the 'claim_requests' collection
                    try {
                      await FirebaseFirestore.instance
                          .collection('claim_requests')
                          .add({
                            'itemId': itemId, // Include item ID
                            'itemName': itemName, // Include item name
                            'claimerName': name,
                            'claimerId': userId,
                            'claimerDepartment': department,
                            'userId':
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                            'claimStatus': 'pending',
                            'submittedAt': Timestamp.now(),
                          });

                      // Optionally, you can also mark the found item as claimed
                      await foundItems.doc(itemId).update({
                        'claimed': true,
                        'claimStatus': 'pending',
                      });

                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Claim submitted successfully!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to submit claim. Please try again.',
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields')),
                    );
                  }
                },
                child: Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reported Found Items'),
        backgroundColor: Color(0xFFBB99CD),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by item name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory ?? 'All',
              items:
                  _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Filter by category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: foundItems.orderBy('date', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading data.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final items =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['itemName'] ?? '').toString().toLowerCase();
                      final category = data['category'] ?? '';
                      final matchesSearch = name.contains(_searchTerm);
                      final matchesCategory =
                          _selectedCategory == null ||
                                  _selectedCategory == 'All'
                              ? true
                              : category == _selectedCategory;
                      return matchesSearch && matchesCategory;
                    }).toList();

                if (items.isEmpty) {
                  return Center(child: Text('No matching items found.'));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['itemName'] ?? 'No name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text("Category: ${data['category'] ?? 'N/A'}"),
                            Text("Location: ${data['location'] ?? 'N/A'}"),
                            Text("Contact: ${data['contactInfo'] ?? 'N/A'}"),
                            if (data['description'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Description: ${data['description']}",
                                ),
                              ),
                            if (data['dateLost'] != null)
                              Text(
                                "Date Lost: ${data['dateLost'] is Timestamp ? (data['dateLost'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : data['dateLost'].toString().split(' ')[0]}",
                              ),
                            if (data['imageUrl'] != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    data['imageUrl'],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Text('Image not available'),
                                  ),
                                ),
                              ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showClaimDialog(
                                    context,
                                    item.id,
                                    data['itemName'],
                                  );
                                },
                                child: Text('Claim Item'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
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
          ),
        ],
      ),
    );
  }
}
