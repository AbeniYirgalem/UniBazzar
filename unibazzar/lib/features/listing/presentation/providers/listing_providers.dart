import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/listing.dart';
import '../../domain/usecases/create_listing.dart';
import '../../domain/usecases/get_listings.dart';
import '../../../listing/data/models/listing_model.dart';
import '../../../../core/di/providers.dart';

class ListingController extends StateNotifier<AsyncValue<List<Listing>>> {
  ListingController({required this.getListings, required this.createListing})
    : super(const AsyncValue.loading()) {
    fetchListings();
  }

  final GetListings getListings;
  final CreateListing createListing;

  Future<void> fetchListings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => getListings());
  }

  Future<void> addListing(ListingModel listing) async {
    final current = state.value ?? [];
    state = const AsyncValue.loading();
    try {
      final created = await createListing(listing);
      state = AsyncValue.data([created, ...current]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final listingControllerProvider =
    StateNotifierProvider<ListingController, AsyncValue<List<Listing>>>(
      (ref) => ListingController(
        getListings: ref.read(getListingsProvider),
        createListing: ref.read(createListingProvider),
      ),
    );

final categoryListingsProvider = FutureProvider.family<List<Listing>, String>((
  ref,
  category,
) {
  final repository = ref.read(listingRepositoryProvider);
  return repository.getListingsByCategory(category);
});
