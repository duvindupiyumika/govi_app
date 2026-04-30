import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/knowledge/data/knowledge_repository.dart';
import '../../features/knowledge/domain/knowledge_guide.dart';
import '../profile/theme_provider.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final _knowledgeRepository = KnowledgeRepository();
  final _searchController = TextEditingController();

  String _selectedCropId = 'all';
  String _selectedCategory = 'all';
  String _query = '';
  bool _isSyncing = false;
  String? _syncMessage;

  static const _categories = {
    'all': 'All',
    'land': 'Land',
    'water': 'Water',
    'fertilizer': 'Fertilizer',
    'pest': 'Pest',
    'disease': 'Disease',
    'general': 'General',
  };

  @override
  void initState() {
    super.initState();
    _knowledgeRepository.seedDefaultsIfEmpty().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _syncGuides() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = null;
    });

    try {
      final count = await _knowledgeRepository.syncFromFirebase();
      if (!mounted) return;
      setState(() {
        _syncMessage = count == 0
            ? 'No online guide updates found.'
            : 'Synced $count guide updates.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _syncMessage = 'Offline mode: showing saved guides.';
      });
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<ThemeProvider>().languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('බෝග දැනුම'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sync guides',
            onPressed: _isSyncing ? null : _syncGuides,
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: StreamBuilder<List<KnowledgeGuide>>(
        stream: _knowledgeRepository.watchAll(),
        builder: (context, snapshot) {
          final guides = _knowledgeRepository.guidesFor(
            languageCode: languageCode,
            cropId: _selectedCropId == 'all' ? null : _selectedCropId,
            category: _selectedCategory,
            query: _query,
          );

          return RefreshIndicator(
            onRefresh: _syncGuides,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                if (_syncMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildSyncMessage(_syncMessage!),
                ],
                const SizedBox(height: 18),
                _buildSearch(),
                const SizedBox(height: 14),
                _buildCropFilters(languageCode),
                const SizedBox(height: 12),
                _buildCategoryFilters(),
                const SizedBox(height: 18),
                if (guides.isEmpty)
                  _buildEmptyState()
                else
                  ...guides.map((guide) => _GuideCard(guide: guide)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.school, color: Colors.green, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Knowledge Base',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Saved crop guides work without internet. Pull down or tap sync for online updates.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'Search guides...',
        prefixIcon: const Icon(Icons.search, color: Colors.green),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(Icons.clear),
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildCropFilters(String languageCode) {
    final entries = [
      const MapEntry('all', 'All crops'),
      ...KnowledgeRepository.cropIds.map(
        (id) => MapEntry(
          id,
          KnowledgeRepository.cropNames[id]?[languageCode] ??
              KnowledgeRepository.cropNames[id]?['en'] ??
              id,
        ),
      ),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return ChoiceChip(
            label: Text(entry.value),
            selected: _selectedCropId == entry.key,
            selectedColor: Colors.green,
            labelStyle: TextStyle(
              color: _selectedCropId == entry.key ? Colors.white : null,
            ),
            onSelected: (_) => setState(() => _selectedCropId = entry.key),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final entries = _categories.entries.toList();

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return FilterChip(
            label: Text(entry.value),
            selected: _selectedCategory == entry.key,
            onSelected: (_) => setState(() => _selectedCategory = entry.key),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'No guides found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different crop, category, or search term.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatefulWidget {
  final KnowledgeGuide guide;

  const _GuideCard({required this.guide});

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(widget.guide.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: categoryColor.withValues(alpha: 0.12),
              child: Icon(
                _categoryIcon(widget.guide.category),
                color: categoryColor,
              ),
            ),
            title: Text(
              widget.guide.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              [
                widget.guide.category,
                if (widget.guide.stageDay != null)
                  'Day ${widget.guide.stageDay}',
              ].join(' • '),
            ),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(widget.guide.description),
                  if (widget.guide.remedy?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(widget.guide.remedy!)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'disease':
        return Icons.coronavirus;
      case 'pest':
        return Icons.bug_report;
      case 'fertilizer':
        return Icons.eco;
      case 'water':
        return Icons.water_drop;
      case 'land':
        return Icons.landscape;
      default:
        return Icons.info;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'disease':
        return Colors.red;
      case 'pest':
        return Colors.orange;
      case 'fertilizer':
        return Colors.green;
      case 'water':
        return Colors.blue;
      case 'land':
        return Colors.brown;
      default:
        return Colors.teal;
    }
  }
}
