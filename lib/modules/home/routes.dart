import 'package:sms_mirror/common.dart';

GoRoute homeRoutes([GlobalKey<NavigatorState>? parentNavigatorKey]) {
  return GoRoute(
    path: HomePage.path,
    builder: (context, state) {
      return const HomePage();
    },
    routes: [
   
    ],
  );
}
