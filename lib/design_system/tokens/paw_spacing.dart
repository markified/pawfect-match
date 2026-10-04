import 'package:flutter/material.dart';



class PawSpacing {
  
  static const double unit = 4.0;

  
  static const double xs = 4.0; 
  static const double sm = 8.0; 
  static const double md = 16.0; 
  static const double lg = 24.0; 
  static const double xl = 32.0; 
  static const double xxl = 48.0; 

  
  static const double contentPadding = md; 
  static const double cardPadding = md; 
  static const double sectionSpacing = lg; 
  static const double screenPadding = md; 
  static const double listItemSpacing = sm; 
  static const double inputSpacing = md; 

  
  static const EdgeInsets contentInsets = EdgeInsets.all(md);
  static const EdgeInsets cardInsets = EdgeInsets.all(md);
  static const EdgeInsets screenInsets = EdgeInsets.all(md);
  static const EdgeInsets listItemInsets = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  
  static const SizedBox verticalXS = SizedBox(height: xs);
  static const SizedBox verticalSM = SizedBox(height: sm);
  static const SizedBox verticalMD = SizedBox(height: md);
  static const SizedBox verticalLG = SizedBox(height: lg);
  static const SizedBox verticalXL = SizedBox(height: xl);
  static const SizedBox verticalXXL = SizedBox(height: xxl);

  
  static const SizedBox horizontalXS = SizedBox(width: xs);
  static const SizedBox horizontalSM = SizedBox(width: sm);
  static const SizedBox horizontalMD = SizedBox(width: md);
  static const SizedBox horizontalLG = SizedBox(width: lg);
  static const SizedBox horizontalXL = SizedBox(width: xl);
  static const SizedBox horizontalXXL = SizedBox(width: xxl);

  
  PawSpacing._();
}
