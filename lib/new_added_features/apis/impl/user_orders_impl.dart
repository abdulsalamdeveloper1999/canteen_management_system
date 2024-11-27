import '../../utils/error_handler.dart';
import '../../utils/firestore_utils.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../base/user_orders_abstract.dart';

class UserOrdersServiceImpl extends UserOrdersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> retrieveUserOrders(String userId) async {
    return await ErrorHandler.handle<List<Map<String, dynamic>>>(
      action: () async {
        QuerySnapshot snapshot = await _firestore
            .collection('orders')
            .where('placed_by', isEqualTo: userId)
            .get();

        return FirestoreUtils.snapshotToList(snapshot);
      },
      errorMessage: 'Could not fetch orders. Please try again later.',
    );
  }

  @override
  Future<Map<String, dynamic>?> getItemDetails(String itemId) async {
    return await ErrorHandler.handle<Map<String, dynamic>?>(
      action: () async {
        // Query Firestore to get the item by item_id
        DocumentSnapshot snapshot = await _firestore
            .collection(
                'items') // Assuming your items are stored in a collection called 'items'
            .doc(itemId)
            .get();

        if (snapshot.exists) {
          return snapshot.data() as Map<String, dynamic>;
        } else {
          return null; // Return null if item doesn't exist
        }
      },
      errorMessage: 'Could not fetch item details. Please try again later.',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> filterUserOrders({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    return await ErrorHandler.handle<List<Map<String, dynamic>>>(
      action: () async {
        Query query =
            _firestore.collection('orders').where('userId', isEqualTo: userId);

        if (startDate != null) {
          query = query.where('placed_at',
              isGreaterThanOrEqualTo: startDate.toIso8601String());
        }

        if (endDate != null) {
          query = query.where('placed_at',
              isLessThanOrEqualTo: endDate.toIso8601String());
        }

        if (status != null) {
          query = query.where('status', isEqualTo: status);
        }

        QuerySnapshot snapshot = await query.get();

        return FirestoreUtils.snapshotToList(snapshot);
      },
      errorMessage: 'Could not filter orders. Please try again later.',
    );
  }
}
