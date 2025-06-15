// screens/intro_screen.dart
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _staggerController;
  late AnimationController _circleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _featureFadeAnimation;
  late Animation<double> _circleAnimation;
  late Animation<double> _imageTextFadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _circleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
    ));

    _featureFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    ));

    _circleAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    ));

    // Same animation timing as button for image and text
    _imageTextFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
    ));

    // Start animations with staggered timing
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _staggerController.dispose();
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F9FF),
              const Color(0xFFE8F4FD),
              const Color(0xFFD4E8F7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top spacing
                  SizedBox(height: screenHeight * 0.02),

                  // Image section with same animation as button
                  FadeTransition(
                    opacity: _imageTextFadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _staggerController,
                        curve: const Interval(0.3, 0.7,
                            curve: Curves.easeOut),
                      )),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Larger image
                          Image.asset(
                            'assets/images/Notes-bro.png',
                            width: screenWidth * 0.85, // Increased from 0.7
                            height: screenHeight * 0.45, // Increased from 0.35
                            fit: BoxFit.contain,
                          ),

                          // Animated decorative circles
                          AnimatedBuilder(
                            animation: _circleAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: 0,
                                right: screenWidth * 0.05,
                                child: Transform.rotate(
                                  angle: _circleAnimation.value * 3.14159,
                                  child: Transform.scale(
                                    scale: 1.0 + (_circleAnimation.value * 0.2),
                                    child: Container(
                                      width: 50, // Increased size
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue[100]!.withOpacity(0.8),
                                            Colors.purple[100]!.withOpacity(0.6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          AnimatedBuilder(
                            animation: _circleAnimation,
                            builder: (context, child) {
                              return Positioned(
                                bottom: 10,
                                left: screenWidth * 0.05,
                                child: Transform.rotate(
                                  angle: -_circleAnimation.value * 3.14159,
                                  child: Transform.scale(
                                    scale: 1.0 + ((_circleAnimation.value + 0.5) % 1.0 * 0.3),
                                    child: Container(
                                      width: 40, // Increased size
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.pink[100]!.withOpacity(0.8),
                                            Colors.orange[100]!.withOpacity(0.6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.pink.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Additional animated circle
                          AnimatedBuilder(
                            animation: _circleAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: screenHeight * 0.15,
                                left: screenWidth * 0.15,
                                child: Transform.rotate(
                                  angle: _circleAnimation.value * 2 * 3.14159,
                                  child: Transform.scale(
                                    scale: 0.8 + ((_circleAnimation.value + 0.3) % 1.0 * 0.4),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green[100]!.withOpacity(0.7),
                                            Colors.teal[100]!.withOpacity(0.5),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Text content section with same animation as button
                  FadeTransition(
                    opacity: _imageTextFadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _staggerController,
                        curve: const Interval(0.3, 0.7,
                            curve: Curves.easeOut),
                      )),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            'Welcome to\nHighlighter',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.08, // Responsive font size
                              fontWeight: FontWeight.w800,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.blue.withOpacity(0.2),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Description
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Capture, organize, and revisit your most important moments from any webpage. Your digital highlights, beautifully organized.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF4A5568),
                                height: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.04),

                          // Action buttons
                          FadeTransition(
                            opacity: _buttonFadeAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _staggerController,
                                curve: const Interval(0.3, 0.7,
                                    curve: Curves.easeOut),
                              )),
                              child: Column(
                                children: [
                                  // Get Started button
                                  SizedBox(
                                    width: screenWidth * 0.7,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                            context, '/home');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF4299E1),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 8,
                                        shadowColor:
                                            Colors.blue.withOpacity(0.3),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Get Started',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.04),

                          SizedBox(height: screenHeight * 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, int index) {
    final colors = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)], // Blue to Purple
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue to Cyan
    ];

    return AnimatedBuilder(
      animation: _featureFadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_featureFadeAnimation.value * 0.2),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors[index % colors.length],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors[index % colors.length][0].withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF4A5568),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}