// calculations.dart
class Calculations {
  static double calculateYield(double avgYieldPerAcre, double landSizeAcres) {
    return avgYieldPerAcre * landSizeAcres;
  }

  static DateTime calculateHarvestDate(DateTime plantingDate, int growingDays) {
    return plantingDate.add(Duration(days: growingDays));
  }

  static String checkSuitability(String crop, String region) {
    // Dummy logic – replace with real AI later
    if (crop == 'Carrot' && region.toLowerCase() == 'anuradhapura') {
      return 'Carrot may not be suitable for Anuradhapura. Consider brinjal.';
    }
    return 'Suitable';
  }
}