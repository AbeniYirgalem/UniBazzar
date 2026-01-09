import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../listing/data/models/listing_model.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required ListingModel listing,
    required super.quantity,
    super.addedAt,
  }) : super(listing: listing);

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final addedAtRaw = json['added_at'] ?? json['addedAt'];
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return CartItemModel(
      listing: ListingModel.fromJson(
        (json['listing'] as Map<String, dynamic>? ?? {})
          ..['id'] = json['listing_id'] ?? json['id'],
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      addedAt: parseDate(addedAtRaw),
    );
  }

  Map<String, dynamic> toJson() {
    final listingModel = listing is ListingModel
        ? listing as ListingModel
        : ListingModel.fromListing(listing);
    return {
      'listing_id': listing.id,
      'listing': listingModel.toJson(),
      'quantity': quantity,
      if (addedAt != null) 'added_at': Timestamp.fromDate(addedAt!),
    };
  }
}
