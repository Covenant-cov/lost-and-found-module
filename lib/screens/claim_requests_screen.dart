import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClaimRequestsScreen extends StatelessWidget {
  static String id = 'claim_requests_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Claim Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4B3F72),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('claim_requests')
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading claim requests.'));
            }

            final claimRequests = snapshot.data!.docs;

            if (claimRequests.isEmpty) {
              return Center(child: Text('No claim requests found.'));
            }

            return ListView.builder(
              itemCount: claimRequests.length,
              itemBuilder: (context, index) {
                final request =
                    claimRequests[index].data() as Map<String, dynamic>;

                final itemName = request['itemName'] ?? 'Unnamed Item';
                final claimerName = request['claimerName'] ?? 'Unknown';
                final claimerId = request['claimerId'] ?? 'N/A';
                final requestStatus = request['status'] ?? 'Pending';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(itemName),
                    subtitle: Text(
                      'Claimed by: $claimerName (ID: $claimerId)\nStatus: $requestStatus',
                    ),
                    trailing: _buildActionButtons(
                      context,
                      claimRequests[index].id,
                      request,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Action buttons for approving or rejecting the claim request
  Widget _buildActionButtons(
    BuildContext context,
    String requestId,
    Map<String, dynamic> request,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.check_circle, color: Colors.green),
          onPressed: () => _approveClaim(context, requestId, request),
        ),
        IconButton(
          icon: Icon(Icons.cancel, color: Colors.red),
          onPressed: () => _rejectClaim(context, requestId),
        ),
      ],
    );
  }

  // Function to approve a claim request and move it to resolved items collection
  void _approveClaim(
    BuildContext context,
    String requestId,
    Map<String, dynamic> request,
  ) async {
    try {
      final claimRequestRef = FirebaseFirestore.instance
          .collection('claim_requests')
          .doc(requestId);

      // Add to resolved_items collection
      await FirebaseFirestore.instance.collection('resolved_items').add({
        'itemName': request['itemName'],
        'claimerName': request['claimerName'],
        'claimerId': request['claimerId'],
        'claimStatus': 'Approved',
        'date': Timestamp.now(),
      });

      // Send notification to user
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': request['userId'], // must exist in request data
        'title': 'Claim Approved',
        'message': 'Your claim for "${request['itemName']}" has been approved.',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Update and remove the original claim request
      await claimRequestRef.update({'status': 'Approved'});
      await claimRequestRef.delete();

      Fluttertoast.showToast(
        msg: 'Claim Approved!',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e', toastLength: Toast.LENGTH_SHORT);
    }
  }

  void _rejectClaim(BuildContext context, String requestId) async {
    try {
      final claimRequestRef = FirebaseFirestore.instance
          .collection('claim_requests')
          .doc(requestId);

      final requestSnapshot = await claimRequestRef.get();
      final request = requestSnapshot.data() as Map<String, dynamic>;

      // Send rejection notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': request['userId'],
        'title': 'Claim Rejected',
        'message': 'Your claim for "${request['itemName']}" was rejected.',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      await claimRequestRef.delete();

      Fluttertoast.showToast(
        msg: 'Claim Rejected!',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e', toastLength: Toast.LENGTH_SHORT);
    }
  }
}
