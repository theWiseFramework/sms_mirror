import 'package:sms_mirror/common.dart';

GoRoute rootRoutes([GlobalKey<NavigatorState>? parentNavigatorKey]) {
  return GoRoute(
    path: RootPage.path,
    builder: (context, state) {
      return const RootPage();
    },
    routes: [
   
    ],
  );
}
