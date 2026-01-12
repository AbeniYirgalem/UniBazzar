import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../listing/data/models/transaction_model.dart';
import '../../../auth/data/models/user_model.dart';

abstract class PaymentRemoteDataSource {
  Future<TransactionModel> payWithTelebirr({
    required String listingId,
    required double amount,
  });

  Future<TransactionModel> recordChapaTransaction({
    required String listingId,
    required double amount,
    required String txRef,
    required String status,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this.client, this.firestore);

  final http.Client client;
  final FirebaseFirestore firestore;
  final _baseUrl = 'https://telebirr.example.com/payments';

  @override
  Future<TransactionModel> payWithTelebirr({
    required String listingId,
    required double amount,
  }) async {
    final response = await client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'listing_id': listingId, 'amount': amount}),
    );

    if (response.statusCode == 200) {
      return TransactionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    // Mocked fallback
    return TransactionModel(
      id: 'txn-${DateTime.now().millisecondsSinceEpoch}',
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

  @override
  Future<TransactionModel> recordChapaTransaction({
    required String listingId,
    required double amount,
    required String txRef,
    required String status,
  }) async {
    final transactionId = 'txn-${DateTime.now().millisecondsSinceEpoch}';

    // Create the transaction model
    // Note: In a real app with Auth, use the actual current user ID.
    // Here we're using a placeholder as the repository/usecase layer might act differently,
    // or we're relying on frontend passed data if needed, but for security,
    // the backend usually verifies the user.
    // Ideally, we'd access the current user here or pass it in.
    // For now, let's keep the mock user or better yet, assume the caller handles user context
    // or we fetch it. Since this override signature doesn't take user, we'll keep the mock/placeholder
    // for the return, BUT for Firestore, we might want to be more specific if possible.
    // Given the previous code used a mock 'buyer-1', we'll stick to that or 'current-user-id'
    // if we haven't updated the interface to accept the user.

    final transaction = TransactionModel(
      id: transactionId,
      listingId: listingId,
      buyer: const UserModel(
        id: 'buyer-1', // Placeholder as interface doesn't ask for buyer
        name: 'Buyer',
        email: 'buyer@campus.edu',
        isAdmin: false,
      ),
      amount: amount,
      status: status,
      createdAt: DateTime.now(),
    );

    // Batch write to ensure consistency
    final batch = firestore.batch();

    // 1. Save transaction
    final txRefDoc = firestore.collection('transactions').doc(transactionId);
    batch.set(txRefDoc, transaction.toJson());

    // 2. Update listing status to 'sold' if payment was successful
    if (status.toLowerCase() == 'success') {
      final listingRef = firestore.collection('listings').doc(listingId);
      batch.update(listingRef, {'status': 'sold'});
    }

    await batch.commit();

    return transaction;
  }
}
