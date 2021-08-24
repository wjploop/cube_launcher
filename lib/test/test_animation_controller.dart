import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: TestAnim(),
  ));
}

class TestAnim extends StatefulWidget {
  const TestAnim({Key? key}) : super(key: key);

  @override
  _TestAnimState createState() => _TestAnimState();
}

class _TestAnimState extends State<TestAnim>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    controller.addListener(() {
      setState(() {
        print('value ${controller.value}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (controller.isCompleted) {
          await controller.animateBack(0);
        } else {
          await controller.animateTo(-1);
        }
      },
      child: Container(
        color: Colors.blue,
        child: Center(
          child: Text("value: ${controller.value}"),
        ),
      ),
    );
  }
}
