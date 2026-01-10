import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/listing_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ListingRemoteDataSource {
  Future<List<ListingModel>> fetchListings();
  Future<List<ListingModel>> fetchListingsByCategory(String category);
  Future<ListingModel> createListing(ListingModel listing);
  Future<TransactionModel> reserveListing({
    required String listingId,
    required double amount,
  });
}

class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  ListingRemoteDataSourceImpl(this.firestore)
    : _collection = firestore.collection('services');

  final FirebaseFirestore firestore;
  final CollectionReference<Map<String, dynamic>> _collection;

  @override
  Future<List<ListingModel>> fetchListings() async {
    final snapshot = await _collection.get();

    final listings = snapshot.docs.map((doc) {
      final data = doc.data();
      final createdAt = _asDateTime(data['created_at'] ?? data['createdAt']);

      final productData = data['product'];
      final product = productData is Map<String, dynamic>
          ? ProductModel.fromJson(productData)
          : ProductModel(
              id: data['product_id']?.toString() ?? doc.id,
              title: data['title'] as String? ?? 'Untitled product',
              description: data['description'] as String? ?? '',
              price: (data['price'] as num?)?.toDouble() ?? 0,
              images:
                  _asStringList(data['images']) ??
                  (data['image'] != null
                      ? [data['image'].toString()]
                      : <String>[]),
              category: data['category'] as String? ?? 'General',
            );

      final sellerData = data['seller'];
      final seller = sellerData is Map<String, dynamic>
          ? UserModel.fromJson(sellerData)
          : UserModel(
              id: data['userId']?.toString() ?? 'unknown-seller',
              name: data['userName'] as String? ?? 'Campus Seller',
              email: data['userEmail'] as String? ?? '',
              isAdmin: data['isAdmin'] as bool? ?? false,
            );

      final phoneNumber =
          (data['phoneNumber'] ?? data['phone_number'] ?? data['phone'])
              ?.toString() ??
          '';

      return ListingModel(
        id: (data['id'] ?? doc.id).toString(),
        product: product,
        seller: seller,
        status: data['status'] as String? ?? 'active',
        createdAt: createdAt ?? DateTime.now(),
        phoneNumber: phoneNumber,
        isFeatured:
            data['is_featured'] as bool? ??
            data['isFeatured'] as bool? ??
            false,
      );
    }).toList();

    listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return listings;
  }

  @override
  Future<List<ListingModel>> fetchListingsByCategory(String category) async {
    final snapshot = await _collection
        .where('product.category', isEqualTo: category)
        .get();

    final listings = snapshot.docs.map((doc) {
      final data = doc.data();
      final createdAt = _asDateTime(data['created_at'] ?? data['createdAt']);

      final productData = data['product'];
      final product = productData is Map<String, dynamic>
          ? ProductModel.fromJson(productData)
          : ProductModel(
              id: data['product_id']?.toString() ?? doc.id,
              title: data['title'] as String? ?? 'Untitled product',
              description: data['description'] as String? ?? '',
              price: (data['price'] as num?)?.toDouble() ?? 0,
              images:
                  _asStringList(data['images']) ??
                  (data['image'] != null
                      ? [data['image'].toString()]
                      : <String>[]),
              category: data['category'] as String? ?? 'General',
            );

      final sellerData = data['seller'];
      final seller = sellerData is Map<String, dynamic>
          ? UserModel.fromJson(sellerData)
          : UserModel(
              id: data['userId']?.toString() ?? 'unknown-seller',
              name: data['userName'] as String? ?? 'Campus Seller',
              email: data['userEmail'] as String? ?? '',
              isAdmin: data['isAdmin'] as bool? ?? false,
            );

      final phoneNumber =
          (data['phoneNumber'] ?? data['phone_number'] ?? data['phone'])
              ?.toString() ??
          '';

      return ListingModel(
        id: (data['id'] ?? doc.id).toString(),
        product: product,
        seller: seller,
        status: data['status'] as String? ?? 'active',
        createdAt: createdAt ?? DateTime.now(),
        phoneNumber: phoneNumber,
        isFeatured:
            data['is_featured'] as bool? ??
            data['isFeatured'] as bool? ??
            false,
      );
    }).toList();

    listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return listings;
  }

  @override
  Future<ListingModel> createListing(ListingModel listing) async {
    final payload = listing.toJson()
      ..['created_at'] = FieldValue.serverTimestamp();

    final docRef = await _collection.add(payload);
    await docRef.update({'id': docRef.id});
    final snapshot = await docRef.get();
    final data = snapshot.data() ?? <String, dynamic>{};

    return ListingModel.fromJson({
      ...data,
      'id': docRef.id,
      'created_at': data['created_at'] ?? Timestamp.now(),
    });
  }

  @override
  Future<TransactionModel> reserveListing({
    required String listingId,
    required double amount,
  }) async {
    // Payments are not implemented yet; stub a pending transaction.
    return TransactionModel(
      id: 'txn-$listingId',
      listingId: listingId,
      buyer: UserModel(
        id: 'buyer-1',
        name: 'You',
        email: 'you@campus.edu',
        isAdmin: false,
      ),
      amount: amount,
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }
}

DateTime? _asDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String>? _asStringList(dynamic value) {
  if (value is Iterable) {
    return value.map((item) => item.toString()).toList();
  }
  return null;
}
