import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

class LogoImage extends StatelessWidget {
  const LogoImage({
    required double width,
    Key? key,
  })  : _width = width,
        super(key: key);

  final double _width;

  @override
  Widget build(BuildContext context) {
    return Image(
      excludeFromSemantics: true,
      width: _width,
      image: const AssetImage(
        'assets/images/pocket-open-access-logo-transparent.png',
      ),
    );
  }
}
