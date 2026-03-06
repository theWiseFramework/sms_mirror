import 'package:sms_mirror/common.dart';

class HomePage extends ConsumerWidget {
  static const path = '/';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSenders = ref.watch(sendersController);
    final size = MediaQuery.sizeOf(context);
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
          Expanded(
            child: asyncSenders.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('An Error')),
              data: (data) {
                return Wrap(
                  children: [SizedBox(width: size.width / 2, child: Icon(Icons.add))],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
