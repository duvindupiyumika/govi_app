class Vegetable {
  final String name;
  final String sinhalaName;
  final double avgYieldPerAcre; // kg
  final int growingDays; // days
  final String suitableClimate;
  final String soilType;
  final double currentPrice; // per kg

  Vegetable({
    required this.name,
    required this.sinhalaName,
    required this.avgYieldPerAcre,
    required this.growingDays,
    required this.suitableClimate,
    required this.soilType,
    required this.currentPrice,
  });

  static final List<Vegetable> samples = [
    Vegetable(
      name: 'Brinjal',
      sinhalaName: 'වම්බටු',
      avgYieldPerAcre: 8000,
      growingDays: 65,
      suitableClimate: 'Warm',
      soilType: 'Loamy',
      currentPrice: 120,
    ),
    Vegetable(
      name: 'Chilli',
      sinhalaName: 'මිරිස්',
      avgYieldPerAcre: 5000,
      growingDays: 75,
      suitableClimate: 'Warm',
      soilType: 'Sandy',
      currentPrice: 350,
    ),
    Vegetable(
      name: 'Pumpkin',
      sinhalaName: 'විවිටක්කා',
      avgYieldPerAcre: 10000,
      growingDays: 55,
      suitableClimate: 'Moderate',
      soilType: 'Loamy',
      currentPrice: 150,
    ),
    Vegetable(
      name: 'Carrot',
      sinhalaName: 'කැරට්',
      avgYieldPerAcre: 10000,
      growingDays: 55,
      suitableClimate: 'Cool',
      soilType: 'Sandy loam',
      currentPrice: 180,
    ),
  ];
}