import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectVegScreen extends StatefulWidget {
  const SelectVegScreen({super.key});

  @override
  State<SelectVegScreen> createState() => _SelectVegScreenState();
}

class _SelectVegScreenState extends State<SelectVegScreen> with SingleTickerProviderStateMixin {
  final List<String> vegetables = const [
    'වම්බටු',
    'මිරිස්',
    'වට්ටක්කා',
    'කැරට්',
    'ගෝවා',
    'බෝංචි',
    'තක්කාලි',
    'කරවිල',
  ];

  final Set<String> _selectedVegetables = {};
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _landSizeController = TextEditingController();
  DateTime? _selectedDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationController.dispose();
    _landSizeController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _locationController.clear();
      _landSizeController.clear();
      _selectedDate = null;
      _selectedVegetables.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('සියලුම දත්ත ඉවත් කරන ලදී'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showHelpBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'උපදෙස්',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('1. ඔබගේ ප්‍රදේශය නිවැරදිව ඇතුලත් කරන්න.'),
              const SizedBox(height: 8),
              const Text('2. වගාව ආරම්භ කිරීමට බලාපොරොත්තු වන දිනය තෝරන්න.'),
              const SizedBox(height: 8),
              const Text('3. බිම් ප්‍රමාණය අක්කර වලින් ඇතුලත් කරන්න.'),
              const SizedBox(height: 8),
              const Text('4. ඔබ කැමති එළවළු වර්ග කිහිපයක් තෝරන්න.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('තේරුණා'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('වගා යෝජනා', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpBottomSheet,
            tooltip: 'උපදෙස්',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearForm,
            tooltip: 'නැවත සකසන්න',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderIcon(),
              const SizedBox(height: 24),
              _buildBasicInfoCard(),
              const SizedBox(height: 24),
              _buildVegetablesCard(),
              const SizedBox(height: 32),
              _buildAnalyzeButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[100],
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.agriculture, size: 60, color: Colors.green[800]),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.green.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'මූලික තොරතුරු',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'ප්‍රදේශය',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.location_on, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'වගා කරන දිනය',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'දිනය තෝරන්න'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: TextStyle(
                    color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _landSizeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'බිම් ප්‍රමාණය (අක්කර)',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.square_foot, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVegetablesCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.green.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'එළවළු වර්ග තෝරන්න',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: vegetables.map((veg) {
                final isSelected = _selectedVegetables.contains(veg);
                return FilterChip(
                  label: Text(veg),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedVegetables.add(veg);
                      } else {
                        _selectedVegetables.remove(veg);
                      }
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: Colors.green,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.grey[300]!,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_locationController.text.isEmpty || _selectedDate == null || _selectedVegetables.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('කරුණාකර සියලුම විස්තර ඇතුළත් කරන්න')),
            );
            return;
          }
          _showAnalysisDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome),
            SizedBox(width: 8),
            Text(
              'AI විශ්ලේෂණය',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalysisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            const Text('AI යෝජනාව'),
          ],
        ),
        content: const Text(
          'ඔබේ ප්‍රදේශයට වම්බටු වගා කිරීම වඩාත් සුදුසුයි.\n\n'
          'අනුරාධපුරට කැරට් සුදුසු නැහැ.\n\n'
          'අප්‍රේල් 25 වෙනිදා වට්ටක්කා හිඟයක් ඇතිවිය හැකි නිසා වට්ටක්කා වගා කිරීමෙන් වැඩි ලාභයක් ලබාගත හැක.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            child: const Text('හරි'),
          ),
        ],
      ),
    );
  }
}