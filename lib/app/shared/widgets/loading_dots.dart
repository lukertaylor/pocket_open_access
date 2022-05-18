import 'dart:math' as math;

import '../common_imports/common_imports_barrel.dart';

class LoadingDots extends StatefulWidget {
  final Color color;
  final String? text;

  const LoadingDots({
    Key? key,
    required this.color,
    this.text,
  }) : super(key: key);

  @override
  LoadingDotsState createState() => LoadingDotsState();
}

class LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animation = Tween(begin: -math.pi, end: math.pi).animate(_controller)
      ..addListener(() => setState(() {}));

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++) ...[
              const SizedBox(
                width: 5,
              ),
              _buildShape(_animation, i),
              const SizedBox(
                width: 5.0,
              )
            ]
          ],
        ),
        ..._addText(widget.text)
      ],
    );
  }

  List<Widget> _addText(String? text) {
    if (text != null) {
      return [
        const SizedBox(
          height: 5.0,
        ),
        Text(text,
            style: const TextStyle(
              fontSize: 15.0,
            )),
      ];
    } else {
      return [];
    }
  }

  Widget _buildShape(Animation<double> animation, int index) {
    return Transform.scale(
      scale: math.sin(animation.value + (-0.5 * index)).abs(),
      child: _itemBuilder(),
    );
  }

  Widget _itemBuilder() {
    return SizedBox.fromSize(
      size: const Size.square(15),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
