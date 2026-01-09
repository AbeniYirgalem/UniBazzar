import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class CreateListing {
  const CreateListing(this.repository);

  final ListingRepository repository;

  Future<Listing> call(Listing listing) => repository.createListing(listing);
}
