import 'package:flutter/material.dart';
import 'package:easy_stars/easy_stars.dart';
import 'package:jobinder/models/review_model.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/providers/review_provider.dart';
import 'package:provider/provider.dart';

class ReviewWidget extends StatefulWidget {
  const ReviewWidget({super.key, required this.revieweeId});

  final String revieweeId;

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  int _rating = 0;
  bool _isSending = false;
  int _starsKey = 0; // Workaround to reset the EasyStarsRating widget when a review is sent

  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> sendReview(int note, String comment) async {
    final reviewProvider = context.read<ReviewProvider>();

    final review = Review(
      reviewer_user: context.read<AuthProvider>().user!.uid,
      reviewee_user: widget.revieweeId,
      comment: comment,
      note: note,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isSending = true;
    });

    try {
      await reviewProvider.addReview(review);

      if (!mounted) return;

      _descriptionController.clear();

      setState(() {
        _rating = 0;
        _starsKey++; // Increment key to force EasyStarsRating widget to rebuild
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send review. Please try again.'),
        ),
      );
    }
  }

  void submitReview() {
    final description = _descriptionController.text.trim();

    if (_rating == 0 || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and a review.')),
      );
      return;
    }

    sendReview(_rating, description);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        // Title
        const Text(
          'Rate your experience',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        // Stars rating
        Center(
          child: EasyStarsRating(
            key: ValueKey(_starsKey),
            initialRating: _rating.toDouble(),
            animateOnRatingChange: true,
            animationConfig: StarAnimationConfig.bounce,
            sizeVariant: StarSizeVariant.large,
            onRatingChanged: _isSending
                ? null
                : (value) {
                    setState(() {
                      _rating = value.round();
                    });
                  },
          ),
        ),

        const SizedBox(height: 20),

        // Comment
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          maxLength: 500,
          enabled: !_isSending,
          decoration: const InputDecoration(
            labelText: 'Review',
            hintText: 'Write your review...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 16),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSending ? null : submitReview,
            child: _isSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit review'),
          ),
        ),
      ],
    );
  }
}
