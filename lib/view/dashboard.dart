import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/translate.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  TranslaterController controller = Get.find<TranslaterController>();
  late AnimationController _animationController;
  final FocusNode _textFieldFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    _textFieldFocusNode.unfocus();
    
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        resizeToAvoidBottomInset: true, 
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6A11CB),
                Color(0xFF2575FC),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Bar (unchanged)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sign Translator',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                   
                    ],
                  ),
                ),

                // Input Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextFormField(
                              focusNode: _textFieldFocusNode,
                              controller: controller.textt,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Type or speak your message',
                                hintStyle: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                              ),
                              onFieldSubmitted: (value) {
                                _dismissKeyboard();
                                controller.WrittenMessage();
                                _startAnimation();
                              },
                            ),
                          ),
                        ),
                        Obx(() => GestureDetector(
                          onTapDown: (details) {
                            _dismissKeyboard();
                            controller.ListernToUser();
                          },
                          onTapUp: (details) {
                            controller.stopListerning();
                            _startAnimation();
                          },
                          child: Container(
                            margin: EdgeInsets.all(8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: controller.isListerning.value == 1 
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.isListerning.value == 1
                                  ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

                // Translation Display
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GetBuilder<TranslaterController>(
                      builder: (Tc) {
                        if (Tc.showsigns.isEmpty) return _buildEmptyState();
                        
                        int currentFrame = (_animationController.value * 
                            (Tc.showsigns.length - 1)).round();
                        
                        return SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 1000),
                                    child: Image.asset(
                                      Tc.showsigns[currentFrame].values.first,
                                      key: ValueKey(Tc.showsigns[currentFrame].values.first),
                                      height: 250,
                                      width: 250,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Sign Language Translation',
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Translate Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _dismissKeyboard();
                      
                      controller.WrittenMessage();
                      _startAnimation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Translate',
                      style: GoogleFonts.nunito(
                        color: Color(0xFF6A11CB),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Empty state widget when no translation is available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.translate,
            size: 100,
            color: Colors.white.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'Start Translating',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Type a message or tap the mic to begin',
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

void _startAnimation() {
  
  _animationController.duration = Duration(
    milliseconds: 500 * controller.showsigns.length,
  );
  _animationController.repeat(reverse: false);
}

}