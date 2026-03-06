import 'package:sms_mirror/common.dart';
import 'package:sms_mirror/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheStorage.init();
  runApp(ProviderScope(child: const SmsMirror()));
}

class SmsMirror extends StatelessWidget {
  const SmsMirror({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
    );
  }
}
