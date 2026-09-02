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
  Stream<List<Review>> watchReviewsForAUser(String userId) async* {
    final userDoc = await _db
        .collection('user')
        .doc(userId)
        .get();
    final role = userDoc.data()?['role'] as String?;

    if (role == null) return;

    yield* _reviewsRef
        .where(
          'reviewee_user',
          isEqualTo: _db.collection(role).doc(userId),
        )
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
              .map((doc) => Review.fromMap(doc.data(), doc.id))
              .toList();

          reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return reviews;
        });
  }

  @override
  Future<void> addReview(Review review) async {
    final revieweeRole = (await _db
      .collection('user')
      .doc(review.reviewee_user)
      .get())
      .data()?['role'] as String?;

    final reviewerRole = (await _db
      .collection('user')
      .doc(review.reviewer_user)
      .get())
      .data()?['role'] as String?;

    await _reviewsRef.add({
      ...review.toMap(),
      'reviewee_user': _db.doc('$revieweeRole/${review.reviewee_user}'),
      'reviewer_user': _db.doc('$reviewerRole/${review.reviewer_user}'),
    });
  }
}
