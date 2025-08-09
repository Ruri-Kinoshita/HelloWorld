import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraOffPage extends StatelessWidget {
  const CameraOffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.push('/role'),
        child: const Text('役割を選択'),
      ),
    );
  }
}