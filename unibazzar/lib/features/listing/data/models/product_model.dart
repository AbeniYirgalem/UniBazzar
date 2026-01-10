import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.images,
    required super.category,
  });

  factory ProductModel.fromProduct(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      description: product.description,
      price: product.price,
      images: product.images,
      category: product.category,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesField = json['images'];
    final singleImage = json['image'];
    final images = imagesField is List
        ? imagesField.map((item) => item.toString()).toList()
        : singleImage != null
        ? [singleImage.toString()]
        : <String>[];

    return ProductModel(
      id: json['id']?.toString() ?? 'unknown',
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? 'No description provided.',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      images: images,
      category: json['category'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'images': images,
    'category': category,
  };
}
