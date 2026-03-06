import 'package:sms_mirror/common.dart';

class HomePage extends ConsumerWidget {
  static const path = '/';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final asyncSenders = ref.watch(sendersController);
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: logoImageHeroTag,
          child: Center(
            child: Image.asset('assets/images/wipay.png', height: 60),
          ),
        ),
        titleSpacing: 1,
      ),
      body: Column(
        children: [
          FutureBuilder<bool>(
            future: getSmsPermissionsStatus(),
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
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(10),
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
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Missing Permissions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Notification or sms permissions are missing',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: requestPermissions,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: Text('GRANT'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          Expanded(
            child: asyncSenders.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('An Error')),
              data: (data) {
                return Wrap(
                  children: [
                    SizedBox(width: size.width / 2, child: Icon(Icons.add)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
