import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/onboarding/data/onboarding_repository.dart';
import '../../features/onboarding/domain/onboarding_profile.dart';
import '../profile/theme_provider.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final _pageController = PageController();
  final _landSizeController = TextEditingController();
  final _manualLocationController = TextEditingController();
  final _cropController = TextEditingController();
  final _onboardingRepository = OnboardingRepository();
  final _uuid = const Uuid();

  int _pageIndex = 0;
  String _languageCode = 'si';
  String _farmerType = 'first_time';
  String _landUnit = 'acres';
  String? _locationLabel;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  DateTime? _startDate;
  final Set<String> _previousCrops = {};
  final Set<String> _marketPreferences = {};

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

  static const Map<String, Map<String, String>> _text = {
    'en': {
      'welcome_title': 'Welcome to GOVI',
      'welcome_subtitle': 'Let us set up farming guidance in your language.',
      'language': 'Choose your language',
      'farmer_title': 'What best describes your farming?',
      'farmer_subtitle': 'This helps GOVI adjust guidance for you.',
      'first_time': 'First-time farmer',
      'small_scale': 'Home garden / small scale',
      'commercial': 'Commercial farmer',
      'location_title': 'Where is your farm?',
      'location_subtitle': 'Location helps weather, soil, and AI guidance.',
      'use_location': 'Use current GPS location',
      'manual_location': 'Or enter nearest town',
      'land_size': 'Land size',
      'crop_title': 'Know what you are planting?',
      'crop_subtitle': 'Optional. You can add crops later from Home.',
      'current_crop': 'Current crop',
      'previous_crop': 'Previous crop',
      'start_date': 'Start date',
      'pick_date': 'Pick date',
      'market_title': 'Choose markets to watch',
      'market_subtitle': 'Optional. Market prices can be changed later.',
      'skip': 'Skip',
      'next': 'Next',
      'finish': 'Finish setup',
      'done_title': 'Your farm is ready',
      'done_subtitle': 'You can now learn, track crops, and ask GOVI AI.',
      'location_required': 'Location is required to continue.',
      'gps_failed': 'Could not get GPS. Enter nearest town instead.',
    },
    'si': {
      'welcome_title': 'GOVI වෙත සාදරයෙන් පිළිගනිමු',
      'welcome_subtitle': 'ඔබට ගැළපෙන භාෂාවෙන් උපදෙස් සකස් කරගනිමු.',
      'language': 'භාෂාව තෝරන්න',
      'farmer_title': 'ඔබේ වගාවට වඩාත් ගැළපෙන්නේ කුමක්ද?',
      'farmer_subtitle': 'මෙය GOVI උපදෙස් ඔබට ගැළපෙන ලෙස සැකසීමට උදව් වේ.',
      'first_time': 'නව ගොවියෙක්',
      'small_scale': 'ගෙවතු / කුඩා පරිමාණ',
      'commercial': 'වාණිජ ගොවියෙක්',
      'location_title': 'ඔබේ ගොවිබිම කොහේද?',
      'location_subtitle': 'කාලගුණය, පස, AI උපදෙස් සඳහා ප්‍රදේශය අවශ්‍යයි.',
      'use_location': 'දැන් GPS ප්‍රදේශය ගන්න',
      'manual_location': 'නැත්නම් ළඟම නගරය ලියන්න',
      'land_size': 'බිම් ප්‍රමාණය',
      'crop_title': 'ඔබ වගා කරන්නේ කුමක්ද?',
      'crop_subtitle': 'අත්‍යවශ්‍ය නැත. පසුව Home එකෙන් බෝග එක් කළ හැක.',
      'current_crop': 'දැනට වගා කරන බෝගය',
      'previous_crop': 'පෙර බෝගය',
      'start_date': 'ආරම්භක දිනය',
      'pick_date': 'දිනය තෝරන්න',
      'market_title': 'බලන්න කැමති වෙළඳපොළවල්',
      'market_subtitle': 'අත්‍යවශ්‍ය නැත. පසුව වෙනස් කළ හැක.',
      'skip': 'මඟහරින්න',
      'next': 'ඊළඟ',
      'finish': 'සකස් කිරීම අවසන්',
      'done_title': 'ඔබේ ගොවිබිම සූදානම්',
      'done_subtitle': 'දැන් ඉගෙන ගන්න, බෝග නිරීක්ෂණය කරන්න, GOVI AI අසන්න.',
      'location_required': 'ඉදිරියට යාමට ප්‍රදේශය අවශ්‍යයි.',
      'gps_failed': 'GPS ලබාගත නොහැකි විය. ළඟම නගරය ලියන්න.',
    },
    'ta': {
      'welcome_title': 'GOVI-க்கு வரவேற்கிறோம்',
      'welcome_subtitle': 'உங்கள் மொழியில் விவசாய வழிகாட்டலை அமைப்போம்.',
      'language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'farmer_title': 'உங்கள் விவசாயத்தை எது விவரிக்கிறது?',
      'farmer_subtitle': 'இதன் மூலம் GOVI உங்களுக்கு ஏற்ற வழிகாட்டலை தரும்.',
      'first_time': 'முதல் முறை விவசாயி',
      'small_scale': 'வீட்டு தோட்டம் / சிறிய அளவு',
      'commercial': 'வணிக விவசாயி',
      'location_title': 'உங்கள் பண்ணை எங்கே?',
      'location_subtitle': 'வானிலை, மண், AI வழிகாட்டலுக்கு இடம் தேவை.',
      'use_location': 'தற்போதைய GPS இடத்தைப் பயன்படுத்து',
      'manual_location': 'அல்லது அருகிலுள்ள நகரம்',
      'land_size': 'நில அளவு',
      'crop_title': 'எதை நடப்பது தெரிகிறதா?',
      'crop_subtitle': 'விருப்பம். பிறகு Home-இல் பயிர் சேர்க்கலாம்.',
      'current_crop': 'தற்போதைய பயிர்',
      'previous_crop': 'முந்தைய பயிர்',
      'start_date': 'தொடக்க தேதி',
      'pick_date': 'தேதி தேர்வு',
      'market_title': 'பார்க்க வேண்டிய சந்தைகள்',
      'market_subtitle': 'விருப்பம். பிறகு மாற்றலாம்.',
      'skip': 'தவிர்',
      'next': 'அடுத்து',
      'finish': 'அமைப்பை முடி',
      'done_title': 'உங்கள் பண்ணை தயார்',
      'done_subtitle':
          'இப்போது கற்கவும், பயிர்களை கண்காணிக்கவும், GOVI AI-ஐ கேட்கவும்.',
      'location_required': 'தொடர இடம் தேவை.',
      'gps_failed': 'GPS கிடைக்கவில்லை. அருகிலுள்ள நகரத்தை உள்ளிடவும்.',
    },
  };

  Map<String, String> get t => _text[_languageCode] ?? _text['si']!;

  @override
  void dispose() {
    _pageController.dispose();
    _landSizeController.dispose();
    _manualLocationController.dispose();
    _cropController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_pageIndex == 2 && !_hasLocation()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t['location_required']!)));
      return;
    }

    if (_pageIndex == 4) {
      await _finish();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  bool _hasLocation() {
    return _locationLabel != null ||
        _manualLocationController.text.trim().isNotEmpty;
  }

  Future<void> _finish() async {
    final now = DateTime.now();
    final location = _locationLabel ?? _manualLocationController.text.trim();
    final landSize = double.tryParse(_landSizeController.text.trim());
    final provider = context.read<ThemeProvider>();

    final profile = OnboardingProfile(
      id: 'local',
      languageCode: _languageCode,
      name: 'Farmer',
      farmerType: _farmerType,
      location: location,
      latitude: _latitude,
      longitude: _longitude,
      landSize: landSize,
      landUnit: landSize == null ? null : _landUnit,
      previousCrops: _previousCrops.toList(),
      activeCrop: _emptyToNull(_cropController.text),
      startDate: _startDate,
      marketPreferences: _marketPreferences.toList(),
      isComplete: true,
      updatedAt: now,
    );

    await _onboardingRepository.save(profile.id, profile, queueSync: false);
    await provider.setLanguage(_languageCode);
    await provider.updateProfile(
      name: 'Farmer_${_uuid.v4().substring(0, 4)}',
      location: location,
      landSize: landSize,
      farmerType: _farmerType,
    );
    await provider.setOnboardingComplete(true);
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
      ).showSnackBar(SnackBar(content: Text(t['gps_failed']!)));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: LinearProgressIndicator(
                value: (_pageIndex + 1) / 5,
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
                  _buildLanguagePage(),
                  _buildFarmerTypePage(),
                  _buildLocationPage(),
                  _buildCropPage(),
                  _buildMarketPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_pageIndex > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
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
                    child: Text(_pageIndex == 4 ? t['finish']! : t['next']!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePage() {
    return _PageFrame(
      icon: Icons.agriculture,
      title: t['welcome_title']!,
      subtitle: t['welcome_subtitle']!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['language']!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _choiceTile('si', 'සිංහල', 'Sri Lanka', Icons.language),
          _choiceTile('ta', 'தமிழ்', 'Sri Lanka', Icons.translate),
          _choiceTile('en', 'English', 'International', Icons.public),
        ],
      ),
    );
  }

  Widget _choiceTile(
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

  Widget _buildFarmerTypePage() {
    return _PageFrame(
      icon: Icons.eco,
      title: t['farmer_title']!,
      subtitle: t['farmer_subtitle']!,
      child: Column(
        children: [
          _farmerTypeCard('first_time', t['first_time']!, Icons.school),
          _farmerTypeCard('small_scale', t['small_scale']!, Icons.home_work),
          _farmerTypeCard('commercial', t['commercial']!, Icons.agriculture),
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

  Widget _buildLocationPage() {
    return _PageFrame(
      icon: Icons.location_on,
      title: t['location_title']!,
      subtitle: t['location_subtitle']!,
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
            label: Text(_locationLabel ?? t['use_location']!),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _manualLocationController,
            decoration: InputDecoration(
              labelText: t['manual_location'],
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
              labelText: t['land_size'],
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.square_foot),
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'acres', label: Text('Acres')),
              ButtonSegment(value: 'perches', label: Text('Perches')),
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

  Widget _buildCropPage() {
    return _PageFrame(
      icon: Icons.spa,
      title: t['crop_title']!,
      subtitle: t['crop_subtitle']!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownMenu<String>(
            controller: _cropController,
            label: Text(t['current_crop']!),
            dropdownMenuEntries: _crops
                .map((crop) => DropdownMenuEntry(value: crop, label: crop))
                .toList(),
          ),
          const SizedBox(height: 16),
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
                  ? t['pick_date']!
                  : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketPage() {
    return _PageFrame(
      icon: Icons.storefront,
      title: t['market_title']!,
      subtitle: t['market_subtitle']!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: 30),
          Icon(Icons.check_circle, color: Colors.green[600], size: 72),
          const SizedBox(height: 12),
          Text(
            t['done_title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(t['done_subtitle']!, textAlign: TextAlign.center),
        ],
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
