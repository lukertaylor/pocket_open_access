import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

/// Provides standard padding around form items.
class FormItemPadding extends StatelessWidget {
  const FormItemPadding({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 0.0),
      child: child,
    );
  }
}
