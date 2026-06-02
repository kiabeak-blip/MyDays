import 'package:flutter/material.dart';

/// Common household/child task emojis grouped by category.
const _categories = {
  'Bedroom': ['🛏️', '🧸', '👕', '🧺', '🪞', '🪟'],
  'Kitchen': ['🍽️', '🥣', '🧽', '🍎', '🥤', '🍳'],
  'Cleaning': ['🧹', '🗑️', '🪣', '🧴', '🫧', '🧻'],
  'Study': ['📚', '📖', '✏️', '📐', '🎒', '🔬'],
  'Health': ['🪥', '🚿', '💊', '🏃', '🧘', '💪'],
  'Fun & Other': ['🎨', '🎵', '🌿', '🐕', '🙏', '⭐'],
};

class IconPicker extends StatelessWidget {
  final String? selected;

  const IconPicker({super.key, this.selected});

  /// Shows the picker sheet and returns the chosen emoji, or null if cleared.
  static Future<String?> show(BuildContext context, String? current) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => IconPicker(selected: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (_, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Choose an icon',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (selected != null && selected!.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: const Text('Remove icon'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _categories.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 0, 6),
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: entry.value.map((emoji) {
                        final isSelected = emoji == selected;
                        return GestureDetector(
                          onTap: () => Navigator.pop(context, emoji),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(emoji,
                                  style: const TextStyle(fontSize: 28)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
