import '../entities/listing.dart';

abstract class ListingRepository {
  Future<List<Listing>> getListings();
  Future<List<Listing>> getListingsByCategory(String category);
  Future<Listing> createListing(Listing listing);
  Future<Listing?> getListingById(String id);
}
