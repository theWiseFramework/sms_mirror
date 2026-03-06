import 'package:sms_mirror/common.dart';

const _historySubPath = 'history';

GoRoute homeRoutes([GlobalKey<NavigatorState>? parentNavigatorKey]) {
  return GoRoute(
    path: HomePage.path,
    builder: (context, state) {
      return const HomePage();
    },
    routes: [
      GoRoute(
        path: _historySubPath,
        builder: (context, state) => const HistoryPage(),
      ),
    ],
  );
}
