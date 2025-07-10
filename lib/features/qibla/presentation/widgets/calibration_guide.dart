import 'package:flutter/material.dart';

class CalibrationGuide extends StatefulWidget {
  const CalibrationGuide({Key? key}) : super(key: key);

  @override
  State<CalibrationGuide> createState() => _CalibrationGuideState();
}

class _CalibrationGuideState extends State<CalibrationGuide>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // Full rotation
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animation
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Instructions
          const Text(
            'Calibrate Compass',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'To improve accuracy, move your phone in a figure-8 pattern several times.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Steps
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.looks_one, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Hold your phone flat'),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.looks_two, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Move in figure-8 pattern'),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.looks_3, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Repeat several times'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}