import 'package:sms_mirror/common.dart';
import 'package:flutter/services.dart';

class HomePage extends ConsumerStatefulWidget {
  static const path = '/';

  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _senderCtrl = TextEditingController();
  final _webhooksCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _senderCtrl.dispose();
    _webhooksCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSender() async {
    final sender = _senderCtrl.text.trim();
    final webhooks = _parseWebhooks(_webhooksCtrl.text);

    if (sender.isEmpty) {
      _showMessage('Sender is required.');
      return;
    }
    if (webhooks.isEmpty) {
      _showMessage('At least one valid webhook is required.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(sendersController.notifier)
          .upsertSender(SenderModel(name: sender, webhooks: webhooks));
      _senderCtrl.clear();
      _webhooksCtrl.clear();
      _showMessage('Sender saved.');
    } on PlatformException catch (e) {
      _showMessage(e.message ?? 'Failed to save sender.');
    } catch (_) {
      _showMessage('Failed to save sender.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _removeSender(SenderModel sender) async {
    try {
      await ref.read(sendersController.notifier).removeSender(sender.name);
      _showMessage('Removed ${sender.name}.');
    } on PlatformException catch (e) {
      _showMessage(e.message ?? 'Failed to remove sender.');
    } catch (_) {
      _showMessage('Failed to remove sender.');
    }
  }

  List<String> _parseWebhooks(String input) {
    final values = input
        .split(RegExp(r'[\n,]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    return values;
  }

  void _editSender(SenderModel sender) {
    _senderCtrl.text = sender.name;
    _webhooksCtrl.text = sender.webhooks.join('\n');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncSenders = ref.watch(sendersController);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 20,
        leading: Center(
          child: Material(
            elevation: 1,
            clipBehavior: Clip.hardEdge,
            shape: HeptagonBorder(
              side: BorderSide(color: Colors.black, width: 3),
            ),
            child: InkWell(
              onTap: () {
                context.push(HistoryPage.path);
              },
              child: SizedBox(
                height: 34,
                width: 34,
                child: Icon(Icons.add_rounded, color: Colors.black87, size: 16),
              ),
            ),
          ),
        ),
        title: Hero(
          tag: logoImageHeroTag,
          child: Center(
            child: Image.asset('assets/images/wipay.png', height: 70),
          ),
        ),
        actions: [
          Material(
            elevation: 1,
            clipBehavior: Clip.hardEdge,
            shape: HeptagonBorder(
              side: BorderSide(color: Colors.black, width: 3),
            ),
            child: InkWell(
              onTap: () {
                context.push(HistoryPage.path);
              },
              child: SizedBox(
                height: 34,
                width: 34,
                child: Icon(
                  Icons.history_rounded,
                  color: Colors.black87,
                  size: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 14),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<bool>(
            future: getPermissionsStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              final hasPermission = snapshot.data ?? false;

              if (!hasPermission) {
                return Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: .1),
                    border: Border.all(color: theme.colorScheme.error),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: theme.colorScheme.error,
                        size: 40,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Missing Permissions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              'SMS and Notification permissions are required to work.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await requestPermissions();
                          if (mounted) setState(() {});
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('GRANT'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _senderCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Sender',
                    hintText: 'MPESA',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _webhooksCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Webhook URLs',
                    hintText: 'One per line or comma separated',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveSender,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'Saving...' : 'Save Sender'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        _senderCtrl.clear();
                        _webhooksCtrl.clear();
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: asyncSenders.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Failed to load senders: $error')),
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text('No senders added yet.'));
                }

                return ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final sender = data[index];
                    return ListTile(
                      title: Text(sender.name),
                      subtitle: Text(
                        sender.webhooks.join('\n'),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _editSender(sender),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove sender',
                        onPressed: () => _removeSender(sender),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
