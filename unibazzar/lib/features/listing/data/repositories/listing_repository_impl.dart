import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_data_source.dart';
import '../models/listing_model.dart';

class ListingRepositoryImpl implements ListingRepository {
  ListingRepositoryImpl(this.remoteDataSource);

  final ListingRemoteDataSource remoteDataSource;

  @override
  Future<Listing> createListing(Listing listing) {
    return remoteDataSource.createListing(listing as ListingModel);
  }

  @override
  Future<List<Listing>> getListings() {
    return remoteDataSource.fetchListings();
  }

  @override
  Future<List<Listing>> getListingsByCategory(String category) {
    return remoteDataSource.fetchListingsByCategory(category);
  }

  @override
  Future<Listing?> getListingById(String id) async {
    final listings = await remoteDataSource.fetchListings();
    try {
      return listings.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
