import 'package:flutter/material.dart';

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final double threshold;

  const SwipeableCard({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.threshold = 0.28,
  });

  @override
  State<SwipeableCard> createState() => SwipeableCardState();
}

class SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset _drag = Offset.zero;
  Offset _start = Offset.zero;
  Offset _end = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          _drag = Offset.lerp(_start, _end, Curves.easeOut.transform(_controller.value))!;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(Offset target, {VoidCallback? then}) {
    _start = _drag;
    _end = target;
    _controller.forward(from: 0).whenComplete(() {
      if (then == null) return;

      _controller.stop();
      setState(() {
        _start = Offset.zero;
        _end = Offset.zero;
        _drag = Offset.zero;
      });
      then();
    });
  }

  /// Triggers the same animation as a manual swipe. Lets the buttons
  /// reuse the gesture, so tapping and swiping look identical.
  void swipe(bool right) {
    final width = MediaQuery.of(context).size.width;
    _animateTo(
      Offset(right ? width * 1.5 : -width * 1.5, 0),
      then: right ? widget.onSwipeRight : widget.onSwipeLeft,
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _drag += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    final width = MediaQuery.of(context).size.width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final passedThreshold = _drag.dx.abs() > width * widget.threshold;
    final flicked = velocity.abs() > 700;

    if (passedThreshold || flicked) {
      final right = passedThreshold ? _drag.dx > 0 : velocity > 0;
      swipe(right);
    } else {
      _animateTo(Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final progress = (_drag.dx / (width * widget.threshold)).clamp(-1.0, 1.0);
    final angle = progress * 0.18; // radians, about 10 degrees at full tilt

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _drag,
        child: Transform.rotate(
          angle: angle,
          child: Stack(
            children: [
              widget.child,
              if (progress != 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: (progress > 0 ? Colors.green : Colors.red)
                            .withOpacity(progress.abs() * 0.25),
                      ),
                      alignment: progress > 0
                          ? Alignment.topLeft
                          : Alignment.topRight,
                      padding: const EdgeInsets.all(24),
                      child: Opacity(
                        opacity: progress.abs(),
                        child: Transform.rotate(
                          angle: progress > 0 ? -0.3 : 0.3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: progress > 0 ? Colors.green : Colors.red,
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              progress > 0 ? 'APPLY' : 'SKIP',
                              style: TextStyle(
                                color:
                                    progress > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}