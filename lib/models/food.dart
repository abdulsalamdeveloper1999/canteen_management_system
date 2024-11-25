class Food {
  String itemName;
  int totalQty;
  int price;
  String id;
  String? imageUrl; // This is the optional image URL

  // Constructor with an optional image parameter
  Food(this.id, this.itemName, this.totalQty, this.price, this.imageUrl);

  // Method to convert the object to a Map for Cart functionality
  Map<String, dynamic> toMapForCart() {
    Map<String, dynamic> map = {};
    map['item_id'] = id;
    map['count'] = 1;
    return map;
  }

  // Optional: Method to convert this object to a Map for Firestore storage or other purposes
  Map<String, dynamic> toMap() {
    return {
      'item_name': itemName,
      'total_qty': totalQty,
      'price': price,
      'id': id,
      'imageUrl': imageUrl, // Include the image URL if available
    };
  }
}
