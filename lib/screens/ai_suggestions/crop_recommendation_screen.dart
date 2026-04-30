import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/ai/data/ai_prediction_repository.dart';
import '../../features/ai/data/gemini_agriculture_service.dart';
import '../../features/ai/domain/ai_prediction.dart';
import '../../features/ai/domain/crop_suggestion_result.dart';
import '../../features/market/data/market_price_repository.dart';
import '../../features/onboarding/data/onboarding_repository.dart';
import '../../features/tracking/data/crop_plan_repository.dart';
import '../profile/theme_provider.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _notesController = TextEditingController();
  final _predictionRepository = AiPredictionRepository();
  final _onboardingRepository = OnboardingRepository();
  final _marketRepository = MarketPriceRepository();
  final _cropPlanRepository = CropPlanRepository();
  final _agricultureService = GeminiAgricultureService();
  final _uuid = const Uuid();

  CropSuggestionResult? _result;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final latest = _predictionRepository.latestByType('crop_suggestion');
    if (latest != null) {
      _result = CropSuggestionResult.fromJson(latest.output);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider = context.read<ThemeProvider>();
    final input = _buildPredictionInput(provider);

    try {
      final result = await _agricultureService.suggestCrop(
        context: input,
        languageCode: provider.languageCode,
      );

      final prediction = AiPrediction(
        id: _uuid.v4(),
        type: 'crop_suggestion',
        input: input,
        output: result.toJson(),
        languageCode: provider.languageCode,
        createdAt: DateTime.now(),
      );
      await _predictionRepository.save(prediction.id, prediction);

      if (!mounted) return;
      setState(() => _result = result);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Could not create a structured recommendation. Check connection and try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _buildPredictionInput(ThemeProvider provider) {
    final profile = provider.profile;
    final onboarding = _onboardingRepository.getById('local');
    final activePlans = _cropPlanRepository.getAll();
    final preferredMarkets = onboarding?.marketPreferences ?? const <String>[];
    final marketPrices = <Map<String, dynamic>>[];

    for (final market in preferredMarkets.take(3)) {
      marketPrices.addAll(
        _marketRepository
            .pricesByMarket(market)
            .take(8)
            .map(
              (price) => {
                'market': price.market,
                'crop': price.cropName,
                'price': price.price,
                'unit': price.unit,
                'updatedAt': price.updatedAt.toIso8601String(),
              },
            ),
      );
    }

    return {
      'farmer': {
        'type': profile.farmerType ?? onboarding?.farmerType,
        'languageCode': provider.languageCode,
        'location': profile.location ?? onboarding?.location,
        'landSize': profile.landSize ?? onboarding?.landSize,
        'landUnit': onboarding?.landUnit ?? 'acres',
      },
      'cropHistory': onboarding?.previousCrops ?? const [],
      'activeCrops': activePlans
          .map(
            (plan) => {
              'crop': plan.cropName,
              'startDate': plan.startDate.toIso8601String(),
              'expectedHarvest': plan.expectedHarvestDate.toIso8601String(),
              'landSize': plan.landSize,
            },
          )
          .toList(),
      'marketPreferences': preferredMarkets,
      'cachedMarketPrices': marketPrices,
      'weather': {
        'source': 'placeholder',
        'note':
            'Weather API is not connected yet. Reason from location and crop season cautiously.',
      },
      'userNotes': _notesController.text.trim(),
      'responseGoal':
          'Recommend one crop that balances farmer context, crop rotation, market risk, and practical next steps.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Smart Crop Suggestion'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Anything GOVI should consider? (optional)',
                hintText:
                    'Example: I prefer short-term crops, low water use...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _getRecommendation,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'Analyzing...' : 'Get Recommendation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(_error!),
            ],
            if (_result != null) ...[
              const SizedBox(height: 22),
              _buildResultCard(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.grass, color: Color(0xFF1B5E20), size: 36),
          SizedBox(height: 12),
          Text(
            'Personalized crop prediction',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'GOVI sends your saved location, farmer type, crop history, active crops, and cached market prices to Gemini for a short structured recommendation.',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _buildResultCard(CropSuggestionResult result) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: Color(0xFF1B5E20), size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.recommendedCrop,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              _ConfidenceBadge(confidence: result.confidence),
            ],
          ),
          const Divider(height: 28),
          Text(result.reasonSummary, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          _InsightRow(title: 'Market', value: result.marketRisk),
          _InsightRow(title: 'Weather', value: result.weatherFit),
          _InsightRow(title: 'Rotation', value: result.soilRotationNote),
          _InsightRow(title: 'Harvest', value: result.expectedHarvestWindow),
          if (result.actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Next actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...result.actions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $action'),
              ),
            ),
          ],
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Warnings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...result.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $warning'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final int confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$confidence%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String title;
  final String value;

  const _InsightRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
