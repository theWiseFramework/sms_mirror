import 'package:flutter/services.dart';
import 'package:sms_mirror/common.dart';
import 'package:sms_mirror/router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  static const path = '/onboarding';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.surface;
    final fgColor = theme.colorScheme.onSurface;
    final btnStyle = OutlinedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      side: BorderSide(color: fgColor.withValues(alpha: .4)),
      fixedSize: const Size(double.maxFinite, 45),
    );
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  bgColor.withValues(alpha: .7),
                  BlendMode.srcATop,
                ),
                child: Image.asset(
                  'assets/images/bg_pattern.png',
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      bgColor.withValues(alpha: .1),
                      bgColor.withValues(alpha: .3),
                      bgColor.withValues(alpha: .8),
                      bgColor,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Spacer(),
                    Hero(
                      tag: logoImageHeroTag,
                      child: Image.asset(
                        'assets/images/wipay.png',
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Hero(
                      tag: logoNameHeroTag,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text.rich(nameLogo()),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Hundreds rely on SmsMirror to automate their sms pipelines. Join them now!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: fgColor.withValues(alpha: .8),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 50),
                    OutlinedButton(
                      onPressed: () {
                        CacheStorage.instance
                            .set(CacheStorage.firstTimeUserKey, false)
                            .then((_) {
                              routeService.refresh();
                              // ignore: use_build_context_synchronously
                              context.go(HomePage.path);
                            });
                      },
                      style: btnStyle,

                      child: const Text(
                        'Get Started Now',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'By using SMS Mirror, you agree to our Terms of Service and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
