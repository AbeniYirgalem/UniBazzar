import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<void> addCartItem({
    required String userId,
    required CartItemModel item,
  });
  Future<List<CartItemModel>> fetchCartItems(String userId);
  Future<void> removeCartItem({
    required String userId,
    required String listingId,
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(this.firestore)
    : _cartsCollection = firestore.collection('carts');

  final FirebaseFirestore firestore;
  final CollectionReference<Map<String, dynamic>> _cartsCollection;

  CollectionReference<Map<String, dynamic>> _itemsCollection(String userId) {
    return _cartsCollection.doc(userId).collection('items');
  }

  @override
  Future<void> addCartItem({
    required String userId,
    required CartItemModel item,
  }) async {
    final payload = item.toJson()..['added_at'] = FieldValue.serverTimestamp();
    await _itemsCollection(
      userId,
    ).doc(item.listing.id).set(payload, SetOptions(merge: true));
  }

  @override
  Future<List<CartItemModel>> fetchCartItems(String userId) async {
    final snapshot = await _itemsCollection(
      userId,
    ).orderBy('added_at', descending: true).get();

    return snapshot.docs
        .map((doc) => CartItemModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<void> removeCartItem({
    required String userId,
    required String listingId,
  }) async {
    await _itemsCollection(userId).doc(listingId).delete();
  }
}
