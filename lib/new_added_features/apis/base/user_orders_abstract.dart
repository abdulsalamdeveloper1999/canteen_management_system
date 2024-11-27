abstract class UserOrdersService {
  /// Fetches all orders for a user
  Future<List<Map<String, dynamic>>> retrieveUserOrders(String userId);

  /// Filters orders by date or status
  Future<List<Map<String, dynamic>>> filterUserOrders({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  });

  Future<Map<String, dynamic>?> getItemDetails(String itemId);
}
