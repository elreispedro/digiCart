import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CentralLogo extends StatefulWidget {
  final double width;
  final double height;

  const CentralLogo({Key? key, this.width = 200, this.height = 200})
      : super(key: key);

  @override
  State<CentralLogo> createState() => _CentralLogoState();
}

class _CentralLogoState extends State<CentralLogo>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Image.asset(
          logoEp,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}
