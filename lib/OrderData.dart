class OrderData {
  final int id;
  final String itemName;
  final double itemPrice;
  final int quantity;
  final DateTime orderDate;

  OrderData({
    required this.id,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    required this.orderDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'quantity': quantity,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}
