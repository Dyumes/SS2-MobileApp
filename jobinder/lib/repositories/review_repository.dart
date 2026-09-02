import 'package:jobinder/models/review_model.dart';

abstract class ReviewRepository {
  Stream<List<Review>> watchReviews();
  Stream<List<Review>> watchReviewsForAUser(String userId);
  Future<void> addReview(Review review);
}
