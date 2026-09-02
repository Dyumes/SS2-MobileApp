import 'package:flutter/material.dart';
import 'package:easy_stars/easy_stars.dart';

class ReviewWidget extends StatefulWidget {
  const ReviewWidget({
    super.key,
    this.onSubmit,
  });

  final void Function(int rating, String description)? onSubmit;

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  int _rating = 0;
  final TextEditingController _descriptionController =
      TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReview() {
    final description = _descriptionController.text.trim();

    if (_rating == 0 || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating and a review.'),
        ),
      );
      return;
    }

    widget.onSubmit?.call(_rating, description);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Rate your experience',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // Star rating
        Center(
          child: EasyStarsRating(
            initialRating: 0.0,
            animateOnRatingChange: true,
            animationConfig: StarAnimationConfig.bounce,
            sizeVariant: StarSizeVariant.large,
            onRatingChanged: (value) {
              setState(() {
                _rating = value.round();
              });
            },
          ),
        ),

        const SizedBox(height: 20),

        // Review text field
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          maxLength: 500,
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
            onPressed: _submitReview,
            child: const Text('Submit review'),
          ),
        ),
      ],
    );
  }
}