import 'package:sms_mirror/common.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final routeService = AppRouteService();

final appRouter = GoRouter(
  initialLocation: HomePage.path,
  navigatorKey: rootNavigatorKey,
  refreshListenable: routeService,
  redirect: routeService.handleRedirect,
  restorationScopeId: 'wipay_router',
  routes: [
    GoRoute(
      path: OnboardingPage.path,
      builder: (context, state) => OnboardingPage(),
    ),
    homeRoutes(),
  ],
);

class AppRouteService extends ChangeNotifier {
  bool showOnboarding =
      CacheStorage.instance.get(CacheStorage.firstTimeUserKey) ?? true;

  String? handleRedirect(BuildContext context, GoRouterState state) {
    if (showOnboarding && state.matchedLocation != OnboardingPage.path) {
      return OnboardingPage.path;
    }
    return null;
  }

  void refresh() {
    showOnboarding =
        CacheStorage.instance.get(CacheStorage.firstTimeUserKey) ?? true;
    notifyListeners();
  }
}
