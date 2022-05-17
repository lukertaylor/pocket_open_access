import '../../../shared/common_imports/common_imports_barrel.dart';

/// Shows a splash screen before replacing with /home route
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.splashTestMode,
    Key? key,
  }) : super(key: key);

  final bool splashTestMode;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    widget.splashTestMode ? null : _autoForwardAfterDelay();
    super.initState();
  }

  void _autoForwardAfterDelay() {
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => Future.delayed(
        const Duration(seconds: 2),
        () => Navigator.pushReplacementNamed(context, '/home'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (screenIsTooSmall(context)) {
      return const ShowTooSmallScreen();
    }

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Flexible(
            flex: 9,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: PocketOpenAccessLogo(screenSize: screenSize),
            ),
          ),
          Flexible(
            flex: 5,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CoreLogo(screenSize: screenSize),
            ),
          ),
          SizedBox(
            height: screenSize.height * 0.1,
          ),
        ],
      ),
    );
  }
}

class CoreLogo extends StatelessWidget {
  const CoreLogo({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Image(
      key: const Key('poweredByCoreLogo'),
      width: screenSize.width * 0.5,
      image: const AssetImage(
        'assets/images/powered-by-core-transparent.png',
      ),
    );
  }
}

class PocketOpenAccessLogo extends StatelessWidget {
  const PocketOpenAccessLogo({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Image(
      semanticLabel: AppLocalizations.of(context)!.loadingSemantic,
      key: const Key('pocketOpenAccessLogo'),
      width: screenSize.width * 0.8,
      image: const AssetImage(
        'assets/images/pocket-open-access-transparent.png',
      ),
    );
  }
}
