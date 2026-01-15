import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class GetListings {
  const GetListings(this.repository);

  final ListingRepository repository;

  Future<List<Listing>> call() => repository.getListings();
}
