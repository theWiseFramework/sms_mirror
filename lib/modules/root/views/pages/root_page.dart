import 'package:sms_mirror/common.dart';

class RootPage extends StatelessWidget {
  static const path = '/root';

  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('RootPage'),
      ),
    );
  }
}
