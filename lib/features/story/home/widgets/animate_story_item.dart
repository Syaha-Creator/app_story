import 'package:flutter/material.dart';

class AnimatedStoryItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedStoryItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<AnimatedStoryItem> createState() => _AnimatedStoryItemState();
}

class _AnimatedStoryItemState extends State<AnimatedStoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 100),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(-1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _offsetAnimation, child: widget.child);
  }
}
