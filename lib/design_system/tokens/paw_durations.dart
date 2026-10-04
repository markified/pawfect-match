

class PawDurations {
  
  static const Duration instant = Duration.zero; 
  static const Duration fast = Duration(milliseconds: 150); 
  static const Duration short = Duration(milliseconds: 200); 
  static const Duration medium = Duration(milliseconds: 300); 
  static const Duration long = Duration(milliseconds: 400); 
  static const Duration xlong = Duration(milliseconds: 500); 

  
  static const Duration microInteraction = fast; 
  static const Duration transition = medium; 
  static const Duration pageTransition = long; 
  static const Duration modalTransition = medium; 
  static const Duration cardAnimation = medium; 
  static const Duration listItemAnimation = short; 

  
  static const Duration snackbar = Duration(seconds: 4); 
  static const Duration tooltip = Duration(seconds: 2); 
  static const Duration successMessage = Duration(milliseconds: 1500); 

  
  static const Duration shimmerCycle = Duration(milliseconds: 1500); 
  static const Duration spinnerRotation = Duration(seconds: 1); 

  
  PawDurations._();
}
