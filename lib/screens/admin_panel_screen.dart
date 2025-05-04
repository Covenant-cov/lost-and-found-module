import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found_fnlyrprj/screens/admin_reported_found_items.dart';
import 'package:lost_and_found_fnlyrprj/screens/pending_approvals_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/resolved_items_screen.dart';

import 'admin_reported_items.dart';
import 'claim_requests_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  static String id = 'admin_panel_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4B3F72),
        leading: PopupMenuButton<String>(
          icon: Icon(Icons.menu, color: Colors.white),
          onSelected: (value) {
            if (value == 'logout') {
              // Perform logout logic
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                'login_screen', // or use LoginScreen.id if defined
                (route) => false,
              );
              // or navigate to login screen
            }
          },
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Overview Cards with Real-Time Data
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('found_items')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                final allItems = snapshot.data!.docs;
                final unclaimed =
                    allItems.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['claimed'] !=
                          true; // Items that are not claimed
                    }).toList();

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildOverviewCard(
                      'Total Found Items',
                      '${allItems.length}',
                      Colors.orange,
                      () {
                        Navigator.pushNamed(
                          context,
                          AdminReportedFoundItems.id,
                        );
                      },
                    ),
                    _buildClaimedItemsCard(),
                    _buildOverviewCard(
                      'Unclaimed Items',
                      '${unclaimed.length}',
                      Colors.red,
                      () {
                        Navigator.pushNamed(
                          context,
                          AdminReportedFoundItems.id,
                        );
                      },
                    ),
                    _buildClaimRequestsCard(),
                  ],
                );
              },
            ),

            SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        PendingApprovalsScreen.id,
                      ); // or use PendingApprovalsScreen.id
                    },
                    icon: Icon(Icons.pending_actions),
                    label: Text('Review Pending Approvals'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4B3F72),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 16), // Space between buttons
                  ElevatedButton.icon(
                    // New button
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AdminReportedItems.id,
                      ); // Navigate to AdminReportedItems
                    },
                    icon: Icon(Icons.list_alt), // Changed the icon
                    label: Text('View Reported Lost Items'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4B3F72),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            Text(
              'Recent Claims',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 12),

            // Dynamic Recent Claims List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('resolved_items')
                        .orderBy('date', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading recent claims.'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(child: Text('No recent claims.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      final claimerName = data['claimerName'] ?? 'Unknown';
                      final claimerId = data['claimerId'] ?? 'N/A';
                      final department = data['claimerDepartment'] ?? 'Unknown';
                      final claimStatus = data['claimStatus'] ?? 'Pending';
                      final date =
                          data['date'] is Timestamp
                              ? (data['date'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                              : 'Unknown Date';

                      return _buildRecentItem(
                        title: data['itemName'] ?? 'Unnamed Item',
                        subtitle:
                            'Claimed by: $claimerName (ID: $claimerId)\nDept: $department\nStatus: $claimStatus',
                        date: date,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // StreamBuilder for Claim Requests card
  Widget _buildClaimRequestsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('claim_requests').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final claimRequests = snapshot.data!.docs;

        return _buildOverviewCard(
          'Claim Requests', // <-- Corrected title
          '${claimRequests.length}',
          Colors.blue,
          // <-- Different color to avoid confusion with 'Claimed Items'
          () {
            Navigator.pushNamed(
              context,
              ClaimRequestsScreen.id,
            ); // Replace with actual screen ID if available
          },
        );
      },
    );
  }

  // StreamBuilder for Claimed Items card
  Widget _buildClaimedItemsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('resolved_items').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final claimedItems = snapshot.data!.docs;

        return _buildOverviewCard(
          'Claimed Items',
          '${claimedItems.length}',
          Colors.green,
          () {
            Navigator.pushNamed(context, ResolvedItemsScreen.id);
          },
        );
      },
    );
  }

  Widget _buildOverviewCard(
    String title,
    String count,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Text(
              count,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem({
    required String title,
    required String subtitle,
    required String date,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text('Date: $date'),
        onTap: () {
          // TODO: Navigate to claim detail or recovery screen
        },
      ),
    );
  }
}
