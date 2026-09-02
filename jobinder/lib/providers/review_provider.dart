import 'package:flutter/material.dart';
import 'package:jobinder/models/review_model.dart';
import '/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository;

  ReviewProvider(this._repository);

  Stream<List<Review>> get reviews => _repository.watchReviews();

  Future<void> addReview(Review review) async {
    await _repository.addReview(review);
  }
  
  Stream<List<Review>> getReviewsForAUser(String userId) {
    return _repository.watchReviewsForAUser(userId);
  }
}