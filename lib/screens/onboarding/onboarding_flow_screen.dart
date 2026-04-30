import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../features/onboarding/data/onboarding_repository.dart';
import '../../features/onboarding/domain/onboarding_profile.dart';
import '../../l10n/app_localizations_context.dart';
import '../../l10n/generated/app_localizations.dart';
import '../profile/theme_provider.dart';

/// Stored in [OnboardingProfile.plantingJourney].
const String kPlantingJourneyKnownCrop = 'known_crop';

const String kPlantingJourneyCropHelp = 'crop_help';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _landSizeController = TextEditingController();
  final _manualLocationController = TextEditingController();

  final _onboardingRepository = OnboardingRepository();

  static const int _dataSteps = 5;
  static const int _completionPageIndex = 5;

  int _pageIndex = 0;
  String _languageCode = 'si';
  String? _farmerType;
  String _landUnit = 'acres';
  String? _locationLabel;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  DateTime? _startDate;
  final Set<String> _previousCrops = {};
  final Set<String> _marketPreferences = {};
  String? _plantingJourney;
  String? _activeCropChoice;
  bool _isCompleting = false;

  static const _crops = [
    'Brinjal',
    'Chilli',
    'Pumpkin',
    'Carrot',
    'Tomato',
    'Beans',
    'Bitter Gourd',
  ];

  static const _markets = [
    'දඹුල්ල',
    'මීගොඩ',
    'නාරහෙන්පිට',
    'තඹුත්තේගම',
    'කැප්පෙටිපොල',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _landSizeController.dispose();
    _manualLocationController.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    final l10n = context.readL10n;
    if (_pageIndex == 1 && _nameController.text.trim().isEmpty) {
      _snack(l10n.onboardingNameRequired);
      return;
    }
    if (_pageIndex == 2 && !_hasLocation()) {
      _snack(l10n.locationRequired);
      return;
    }
    if (_pageIndex == 4 && _plantingJourney == null) {
      _snack(l10n.onboardingJourneyRequired);
      return;
    }

    if (_pageIndex == _completionPageIndex - 1) {
      await _pageController.animateToPage(
        _completionPageIndex,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _hasLocation() {
    return _locationLabel != null ||
        _manualLocationController.text.trim().isNotEmpty;
  }

  Future<void> _persistAndComplete() async {
    if (_isCompleting) return;
    final l10n = context.readL10n;

    final name = _nameController.text.trim();
    if (_languageCode.trim().isEmpty) {
      _snack(l10n.chooseLanguage);
      return;
    }
    if (name.isEmpty) {
      _snack(l10n.onboardingNameRequired);
      return;
    }
    if (!_hasLocation()) {
      _snack(l10n.locationRequired);
      return;
    }
    if (_plantingJourney == null) {
      _snack(l10n.onboardingJourneyRequired);
      return;
    }

    setState(() => _isCompleting = true);
    try {
      final provider = context.read<ThemeProvider>();
      final now = DateTime.now();
      final location = (_locationLabel ?? _manualLocationController.text.trim());

      final knowPath = _plantingJourney == kPlantingJourneyKnownCrop;
      final landSize = double.tryParse(_landSizeController.text.trim());

      final profile = OnboardingProfile(
        id: 'local',
        languageCode: _languageCode,
        name: name,
        farmerType: _farmerType,
        location: location,
        latitude: _latitude,
        longitude: _longitude,
        landSize: landSize,
        landUnit: landSize == null ? null : _landUnit,
        previousCrops: knowPath ? _previousCrops.toList() : const [],
        activeCrop:
            knowPath ? _emptyToNull(_activeCropChoice ?? '') : null,
        startDate: knowPath ? _startDate : null,
        marketPreferences: _marketPreferences.toList(),
        plantingJourney: _plantingJourney,
        isComplete: true,
        updatedAt: now,
      );

      await _onboardingRepository.save(profile.id, profile, queueSync: false);
      await provider.setLanguage(_languageCode);
      await provider.updateProfile(
        name: name,
        location: location,
        landSize: landSize,
        farmerType: _farmerType,
      );
      await provider.setOnboardingComplete(true);
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationServiceDisabledException();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const PermissionDeniedException('Location permission denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      final lat = position.latitude.toStringAsFixed(4);
      final lng = position.longitude.toStringAsFixed(4);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationLabel = 'GPS $lat, $lng';
        _manualLocationController.clear();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.readL10n.gpsFailed)));
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _skipOptionalPreferencesPage() {
    _advance();
  }

  double get _progressValue {
    if (_pageIndex >= _completionPageIndex) return 1;
    return (_pageIndex + 1) / _dataSteps;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: LinearProgressIndicator(
                value: _progressValue,
                color: Colors.green,
                backgroundColor: Colors.green.withValues(alpha: 0.12),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _pageIndex = index),
                children: [
                  _buildLanguagePage(l10n),
                  _buildNamePage(l10n),
                  _buildLocationPage(l10n),
                  _buildPreferencesPage(l10n),
                  _buildJourneyPage(l10n),
                  _buildCompletionPage(l10n),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _pageIndex >= _completionPageIndex
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCompleting ? null : _persistAndComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isCompleting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(l10n.onboardingEnterApp),
                      ),
                    )
                  : Row(
                      children: [
                        if (_pageIndex > 0)
                          TextButton(
                            onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                            child: Text(l10n.back),
                          ),
                        if (_pageIndex == 3)
                          TextButton(
                            onPressed: _skipOptionalPreferencesPage,
                            child: Text(l10n.skip),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _advance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.next),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePage(AppLocalizations l10n) {
    return _PageFrame(
      icon: Icons.agriculture,
      title: l10n.welcomeTitle,
      subtitle: l10n.welcomeSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chooseLanguage,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _languageTile('si', 'සිංහල', l10n.languageRegionLk, Icons.language),
          _languageTile('ta', 'தமிழ்', l10n.languageRegionLk, Icons.translate),
          _languageTile(
            'en',
            'English',
            l10n.languageRegionIntl,
            Icons.public,
          ),
        ],
      ),
    );
  }

  Widget _languageTile(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final selected = _languageCode == value;
    return Card(
      color: selected ? Colors.green[50] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? Colors.green : Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: selected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () {
          setState(() => _languageCode = value);
          context.read<ThemeProvider>().setLanguage(value);
        },
      ),
    );
  }

  Widget _buildNamePage(AppLocalizations l10n) {
    return _PageFrame(
      icon: Icons.badge_outlined,
      title: l10n.onboardingNameTitle,
      subtitle: l10n.onboardingNameSubtitle,
      child: TextField(
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: l10n.onboardingYourName,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.person_outline),
        ),
      ),
    );
  }

  Widget _buildLocationPage(AppLocalizations l10n) {
    return _PageFrame(
      icon: Icons.location_on,
      title: l10n.locationTitle,
      subtitle: l10n.locationSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _isLocating ? null : _useCurrentLocation,
            icon: _isLocating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              _manualLocationController.text.isEmpty &&
                      _locationLabel != null
                  ? _locationLabel!
                  : l10n.useGpsLocation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextField(
            controller: _manualLocationController,
            decoration: InputDecoration(
              labelText: l10n.manualLocation,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.map_outlined),
            ),
            onChanged: (_) => setState(() => _locationLabel = null),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _landSizeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.landSize,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.square_foot),
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'acres', label: Text(l10n.landUnitAcres)),
              ButtonSegment(
                value: 'perches',
                label: Text(l10n.landUnitPerches),
              ),
            ],
            selected: {_landUnit},
            onSelectionChanged: (values) {
              setState(() => _landUnit = values.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage(AppLocalizations l10n) {
    return _PageFrame(
      icon: Icons.tune,
      title: l10n.onboardingPreferencesTitle,
      subtitle: l10n.onboardingPreferencesSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.farmerTypeTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            l10n.farmerTypeSubtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          _farmerTypeCard('first_time', l10n.farmerFirstTime, Icons.school),
          _farmerTypeCard(
            'small_scale',
            l10n.farmerSmallScale,
            Icons.home_work,
          ),
          _farmerTypeCard(
            'commercial',
            l10n.farmerCommercial,
            Icons.agriculture,
          ),
          const SizedBox(height: 28),
          Text(l10n.marketTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            l10n.marketSubtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _markets.map((market) {
              return FilterChip(
                label: Text(market),
                selected: _marketPreferences.contains(market),
                onSelected: (selected) {
                  setState(() {
                    selected
                        ? _marketPreferences.add(market)
                        : _marketPreferences.remove(market);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _farmerTypeCard(String value, String title, IconData icon) {
    final selected = _farmerType == value;
    return Card(
      color: selected ? Colors.green[50] : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(title),
        trailing: selected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () => setState(() => _farmerType = value),
      ),
    );
  }

  Widget _buildJourneyPage(AppLocalizations l10n) {
    final known = _plantingJourney == kPlantingJourneyKnownCrop;

    return _PageFrame(
      icon: Icons.route,
      title: l10n.onboardingJourneyTitle,
      subtitle: l10n.onboardingJourneySubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _journeyCard(
            selected: known,
            title: l10n.onboardingJourneyKnownTitle,
            body: l10n.onboardingJourneyKnownBody,
            icon: Icons.local_florist,
            onTap: () {
              setState(() => _plantingJourney = kPlantingJourneyKnownCrop);
            },
          ),
          const SizedBox(height: 12),
          _journeyCard(
            selected: _plantingJourney == kPlantingJourneyCropHelp,
            title: l10n.onboardingJourneyHelpTitle,
            body: l10n.onboardingJourneyHelpBody,
            icon: Icons.psychology_outlined,
            onTap: () {
              setState(() {
                _plantingJourney = kPlantingJourneyCropHelp;
                _activeCropChoice = null;
                _startDate = null;
                _previousCrops.clear();
              });
            },
          ),
          if (known) ...[
            const SizedBox(height: 24),
            Text(l10n.cropTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              l10n.cropSubtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _activeCropChoice,
              decoration: InputDecoration(
                labelText: l10n.currentCrop,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.skip),
                ),
                ..._crops.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c,
                    child: Text(c),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _activeCropChoice = v),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.previousCrop,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _crops.map((crop) {
                return FilterChip(
                  label: Text(crop),
                  selected: _previousCrops.contains(crop),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _previousCrops.add(crop)
                          : _previousCrops.remove(crop);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickStartDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _startDate == null
                    ? l10n.pickDate
                    : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _journeyCard({
    required bool selected,
    required String title,
    required String body,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        color: selected ? Colors.green[50] : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side:
              BorderSide(color: selected ? Colors.green.shade700 : Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.green[700], size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      style:
                          TextStyle(fontSize: 14, height: 1.35, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionPage(AppLocalizations l10n) {
    return _PageFrame(
      icon: Icons.celebration,
      title: l10n.onboardingCompleteTitle,
      subtitle: l10n.onboardingCompleteSubtitle,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Icon(Icons.check_circle, color: Colors.green[600], size: 80),
      ),
    );
  }
}

class _PageFrame extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _PageFrame({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 42, color: Colors.green[700]),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 30),
          child,
        ],
      ),
    );
  }
}
