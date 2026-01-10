import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/listing.dart';
import 'product_model.dart';

class ListingModel extends Listing {
  const ListingModel({
    required super.id,
    required super.product,
    required super.seller,
    required super.status,
    required super.createdAt,
    required super.phoneNumber,
    super.isFeatured,
  });

  factory ListingModel.fromListing(Listing listing) {
    final product = listing.product;
    final seller = listing.seller;
    return ListingModel(
      id: listing.id,
      product: product is ProductModel
          ? product
          : ProductModel.fromProduct(product),
      seller: seller is UserModel ? seller : UserModel.fromUser(seller),
      status: listing.status,
      createdAt: listing.createdAt,
      phoneNumber: listing.phoneNumber,
      isFeatured: listing.isFeatured,
    );
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final productRaw = json['product'];
    final product = productRaw is Map<String, dynamic>
        ? ProductModel.fromJson(productRaw)
        : ProductModel(
            id:
                json['product_id']?.toString() ??
                json['id']?.toString() ??
                'unknown',
            title: json['title'] as String? ?? 'Untitled product',
            description: json['description'] as String? ?? '',
            price: (json['price'] as num?)?.toDouble() ?? 0,
            images:
                (json['images'] as List?)
                    ?.map((item) => item.toString())
                    .toList() ??
                (json['image'] != null
                    ? [json['image'].toString()]
                    : <String>[]),
            category: json['category'] as String? ?? 'General',
          );

    final sellerRaw = json['seller'];
    final seller = sellerRaw is Map<String, dynamic>
        ? UserModel.fromJson(sellerRaw)
        : UserModel(
            id: json['userId']?.toString() ?? 'unknown-seller',
            name: json['userName'] as String? ?? 'Campus Seller',
            email: json['userEmail'] as String? ?? '',
            isAdmin: json['isAdmin'] as bool? ?? false,
          );

    final phone =
        (json['phoneNumber'] ?? json['phone_number'] ?? json['phone'])
            ?.toString() ??
        '';

    return ListingModel(
      id: json['id']?.toString() ?? 'unknown',
      product: product,
      seller: seller,
      status: json['status'] as String? ?? 'active',
      createdAt:
          parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      phoneNumber: phone,
      isFeatured:
          json['is_featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product': (product as ProductModel).toJson(),
    'seller': (seller as UserModel).toJson(),
    'status': status,
    'created_at': Timestamp.fromDate(createdAt),
    'phoneNumber': phoneNumber,
    'is_featured': isFeatured,
  };
}
