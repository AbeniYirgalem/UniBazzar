import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/login_with_google.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/listing/data/datasources/listing_remote_data_source.dart';
import '../../features/listing/data/repositories/listing_repository_impl.dart';
import '../../features/listing/domain/repositories/listing_repository.dart';
import '../../features/listing/domain/usecases/create_listing.dart';
import '../../features/listing/domain/usecases/get_listings.dart';
import '../../features/payment/data/datasources/payment_remote_data_source.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/data/datasources/cart_remote_data_source.dart';
import '../../features/payment/data/repositories/cart_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/make_payment.dart';
import '../../features/payment/domain/repositories/cart_repository.dart';
import '../../features/payment/domain/usecases/add_to_cart.dart';
import '../../features/payment/domain/usecases/get_cart_items.dart';
import '../../features/payment/domain/usecases/remove_from_cart.dart';
import '../services/auth_service.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());
final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.read(firebaseAuthProvider),
    ref.read(googleSignInProvider),
  ),
);

// Data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.read(authServiceProvider)),
);

final listingRemoteDataSourceProvider = Provider<ListingRemoteDataSource>(
  (ref) => ListingRemoteDataSourceImpl(ref.read(firebaseFirestoreProvider)),
);

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>(
  (ref) => PaymentRemoteDataSourceImpl(
    ref.read(httpClientProvider),
    ref.read(firebaseFirestoreProvider),
  ),
);

final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>(
  (ref) => CartRemoteDataSourceImpl(ref.read(firebaseFirestoreProvider)),
);

// Repositories
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider)),
);

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ListingRepositoryImpl(ref.read(listingRemoteDataSourceProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepositoryImpl(ref.read(paymentRemoteDataSourceProvider)),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepositoryImpl(
    ref.read(cartRemoteDataSourceProvider),
    ref.read(authServiceProvider),
  ),
);

// Use cases
final loginUserProvider = Provider<LoginUser>(
  (ref) => LoginUser(ref.read(authRepositoryProvider)),
);

final loginWithGoogleProvider = Provider<LoginWithGoogle>(
  (ref) => LoginWithGoogle(ref.read(authRepositoryProvider)),
);

final registerUserProvider = Provider<RegisterUser>(
  (ref) => RegisterUser(ref.read(authRepositoryProvider)),
);

final getListingsProvider = Provider<GetListings>(
  (ref) => GetListings(ref.read(listingRepositoryProvider)),
);

final createListingProvider = Provider<CreateListing>(
  (ref) => CreateListing(ref.read(listingRepositoryProvider)),
);

final makePaymentProvider = Provider<MakePayment>(
  (ref) => MakePayment(ref.read(paymentRepositoryProvider)),
);

final addToCartProvider = Provider<AddToCart>(
  (ref) => AddToCart(ref.read(cartRepositoryProvider)),
);

final getCartItemsProvider = Provider<GetCartItems>(
  (ref) => GetCartItems(ref.read(cartRepositoryProvider)),
);

final removeFromCartProvider = Provider<RemoveFromCart>(
  (ref) => RemoveFromCart(ref.read(cartRepositoryProvider)),
);
