class Order {
  final String id;
  final String status;
  final DateTime placedAt;
  final double totalAmount;

  Order({
    required this.id,
    required this.status,
    required this.placedAt,
    required this.totalAmount,
  });
}
