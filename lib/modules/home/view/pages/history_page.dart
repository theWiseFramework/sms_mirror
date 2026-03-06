import 'package:sms_mirror/common.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});
  static const path = '/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(smsHistoryStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MIRROR HISTORY')),
      body: asyncHistory.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load history stream: $error'),
            ),
          );
        },
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No tracked SMS yet.\nWhen incoming SMS from tracked senders arrive, they will appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(smsHistoryStreamProvider.future),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.sender,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _StatusChip(label: item.syncStateLabel),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(item.timestampMillis),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Attempts: ${item.attempts} | Parts: ${item.partsCount}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (item.lastError != null &&
                            item.lastError!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.lastError!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  isThreeLine: true,
                );
              },
            ),
          );
        },
      ),
    );
  }

  static String _formatTimestamp(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}:${_two(dt.second)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final upper = label.toUpperCase();
    final theme = Theme.of(context);
    final (fg, bg) = _resolveColor(theme, upper);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withValues(alpha: .6)),
      ),
      child: Text(
        upper,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  (Color, Color) _resolveColor(ThemeData theme, String upper) {
    if (upper == 'SYNCED') {
      return (Colors.green.shade800, Colors.green.shade50);
    }
    if (upper == 'FAILED') {
      return (theme.colorScheme.error, theme.colorScheme.errorContainer);
    }
    if (upper == 'IN_FLIGHT') {
      return (Colors.blue.shade800, Colors.blue.shade50);
    }
    if (upper == 'RETRY') {
      return (Colors.orange.shade800, Colors.orange.shade50);
    }
    return (Colors.grey.shade800, Colors.grey.shade200);
  }
}
