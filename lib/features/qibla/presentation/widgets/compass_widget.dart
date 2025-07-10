import 'dart:math' as math;
import 'package:flutter/material.dart';

class CompassWidget extends StatefulWidget {
  final double qiblaDirection;
  final double compassHeading;
  final bool isPointingToQibla;

  const CompassWidget({
    Key? key,
    required this.qiblaDirection,
    required this.compassHeading,
    required this.isPointingToQibla,
  }) : super(key: key);

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isPointingToQibla) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CompassWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isPointingToQibla && !oldWidget.isPointingToQibla) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isPointingToQibla && oldWidget.isPointingToQibla) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass Background
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -widget.compassHeading * (math.pi / 180),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.grey.shade100,
                        Colors.grey.shade200,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: CompassBackgroundPainter(),
                  ),
                ),
              );
            },
          ),
          
          // Qibla Direction Indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: (widget.qiblaDirection - widget.compassHeading) * (math.pi / 180),
                child: Transform.scale(
                  scale: widget.isPointingToQibla ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 200),
                    decoration: BoxDecoration(
                      color: widget.isPointingToQibla ? Colors.green : Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isPointingToQibla ? Colors.green : Colors.amber)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mosque,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Compass Needle
          Transform.rotate(
            angle: 0, // Needle stays fixed, compass rotates
            child: Container(
              width: 4,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.red,
                    Colors.white,
                  ],
                  stops: [0.0, 0.5],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          
          // Center Dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          
          // Accuracy Ring
          if (widget.isPointingToQibla)
            Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green.withOpacity(0.5),
                  width: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom painter for compass background
class CompassBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.grey.shade400;
    
    // Draw direction markers
    for (int i = 0; i < 360; i += 30) {
      final angle = i * (math.pi / 180);
      final startRadius = radius - 20;
      final endRadius = radius - 10;
      
      final start = Offset(
        center.dx + startRadius * math.cos(angle - math.pi / 2),
        center.dy + startRadius * math.sin(angle - math.pi / 2),
      );
      
      final end = Offset(
        center.dx + endRadius * math.cos(angle - math.pi / 2),
        center.dy + endRadius * math.sin(angle - math.pi / 2),
      );
      
      paint.strokeWidth = i % 90 == 0 ? 3 : 1;
      canvas.drawLine(start, end, paint);
    }
    
    // Draw cardinal directions
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = i * (math.pi / 2);
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      );
      
      textPainter.layout();
      
      final textRadius = radius - 35;
      final textPosition = Offset(
        center.dx + textRadius * math.cos(angle - math.pi / 2) - textPainter.width / 2,
        center.dy + textRadius * math.sin(angle - math.pi / 2) - textPainter.height / 2,
      );
      
      textPainter.paint(canvas, textPosition);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}