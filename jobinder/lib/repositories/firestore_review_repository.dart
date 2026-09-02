import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobinder/models/review_model.dart';
import 'package:jobinder/repositories/review_repository.dart';


class FirestoreReviewRepository extends ReviewRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reviewsRef =>
      _db.collection('reviews');

  @override
  Stream<List<Review>> watchReviews() {
    return _reviewsRef.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          return Review.fromMap(doc.data(), doc.id);
        }).toList());
  }

  @override
  Stream<List<Review>> watchReviewsForAUser(String userId) {
    return _reviewsRef.where('reviewee_id', isEqualTo: userId).snapshots().map((snapshot) => snapshot.docs.map((doc) {
          return Review.fromMap(doc.data(), doc.id);
        }).toList());
  }

  @override
  Future<void> addReview(Review review) async{
    await _reviewsRef.add(review.toMap());
  }
}
