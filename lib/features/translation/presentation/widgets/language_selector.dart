import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  final String sourceLang, targetLang;
  final ValueChanged<String> onSourceChanged, onTargetChanged;
  const LanguageSelector({super.key, required this.sourceLang, required this.targetLang,
    required this.onSourceChanged, required this.onTargetChanged});

  static const _languages = {
    'auto': 'Detect', 'en': 'English', 'es': 'Spanish', 'fr': 'French', 'de': 'German',
    'it': 'Italian', 'pt': 'Portuguese', 'ru': 'Russian', 'zh': 'Chinese', 'ja': 'Japanese',
    'ko': 'Korean', 'ar': 'Arabic', 'hi': 'Hindi', 'bn': 'Bengali', 'pa': 'Punjabi',
    'ta': 'Tamil', 'te': 'Telugu', 'mr': 'Marathi', 'gu': 'Gujarati', 'ur': 'Urdu',
    'tr': 'Turkish', 'nl': 'Dutch', 'pl': 'Polish', 'sv': 'Swedish', 'da': 'Danish',
    'fi': 'Finnish', 'cs': 'Czech', 'ro': 'Romanian', 'hu': 'Hungarian', 'el': 'Greek',
    'he': 'Hebrew', 'th': 'Thai', 'vi': 'Vietnamese', 'id': 'Indonesian', 'ms': 'Malay',
  };

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      Expanded(child: _Dropdown(label: 'From', value: sourceLang, items: _languages, onChanged: onSourceChanged)),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: AppColors.translationColor)),
      Expanded(child: _Dropdown(label: 'To', value: targetLang, items: _languages..remove('auto'), onChanged: onTargetChanged)),
    ]),
  );
}

class _Dropdown extends StatelessWidget {
  final String label, value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;
  const _Dropdown({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: Theme.of(context).textTheme.labelSmall),
    const SizedBox(height: 4),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: AppColors.translationColor.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: items.containsKey(value) ? value : items.keys.first,
        isExpanded: true,
        items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      )),
    ),
  ]);
}
