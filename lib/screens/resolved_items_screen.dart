import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResolvedItemsScreen extends StatefulWidget {
  static String id = 'resolved_items_screen';

  @override
  _ResolvedItemsScreenState createState() => _ResolvedItemsScreenState();
}

class _ResolvedItemsScreenState extends State<ResolvedItemsScreen> {
  final CollectionReference resolvedItems = FirebaseFirestore.instance
      .collection('resolved_items');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resolved Items'),
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
              stream:
                  resolvedItems
                      .orderBy('dateLost', descending: true)
                      .snapshots(),
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
                  return Center(child: Text('No resolved items found.'));
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.restore,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Restore to Lost Items',
                                    onPressed: () async {
                                      bool confirm = await showDialog(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                              title: Text('Restore Item?'),
                                              content: Text(
                                                'Are you sure you want to move this back to Lost Items?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        ctx,
                                                        false,
                                                      ),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        ctx,
                                                        true,
                                                      ),
                                                  child: Text('Restore'),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirm) {
                                        try {
                                          final itemData =
                                              item.data()
                                                  as Map<String, dynamic>;
                                          await FirebaseFirestore.instance
                                              .collection('lost_items')
                                              .add(itemData);
                                          await resolvedItems
                                              .doc(item.id)
                                              .delete();

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Item restored to Lost Items',
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to restore item',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
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
          ),
        ],
      ),
    );
  }
}
