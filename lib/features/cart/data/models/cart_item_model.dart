class CartItemModel {
  final int productId;
  final int quantity;

  CartItemModel({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] as int,
      quantity: map['quantity'] as int,
    );
  }
}
