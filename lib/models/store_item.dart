class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final bool isCosmetic;
  final String icon;
  /// Max units a player can hold. -1 = unlimited.
  final int maxStack;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isCosmetic,
    required this.icon,
    this.maxStack = -1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'isCosmetic': isCosmetic,
      'icon': icon,
      'maxStack': maxStack,
    };
  }

  factory StoreItem.fromMap(Map<String, dynamic> map) {
    return StoreItem(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as int,
      isCosmetic: map['isCosmetic'] as bool,
      icon: map['icon'] as String,
      maxStack: map['maxStack'] as int? ?? -1,
    );
  }
}
