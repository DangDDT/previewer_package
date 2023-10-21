import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class GetView2<T, X> extends StatelessWidget {
  const GetView2({Key? key}) : super(key: key);

  final String? tag1 = null;

  final String? tag2 = null;

  T get controller1 => GetInstance().find<T>(tag: tag1)!;

  X get controller2 => GetInstance().find<X>(tag: tag2)!;

  @override
  Widget build(BuildContext context);
}
