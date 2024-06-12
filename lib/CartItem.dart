class CartItem {
  final int productId;
  final String name;
  final double price;
  final String imagePath;
  int quantity;

  CartItem(this.productId, this.name, this.price, this.imagePath, this.quantity);
  Map<String, dynamic> toMap() {
    return {
      'id': productId,
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'quantity': quantity,
    };

  }

}
