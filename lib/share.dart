import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Sharepage extends StatefulWidget {
  const Sharepage({super.key});

  @override
  State<Sharepage> createState() => _SharepageState();
}

class _SharepageState extends State<Sharepage> {
  late Future<String?> _photoUrlFuture;

  @override
  void initState() {
    super.initState();
    _photoUrlFuture = _getPhotoUrl();
  }

  Future<String?> _getPhotoUrl() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('ribbon_red_02.png'); //ここで表示する画像変えれる
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('画像取得失敗: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<String?>(
          future: _photoUrlFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Text('画像が取得できませんでした');
            }
            final url = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '最終盤のプロフィールが出るページ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    url,
                    width: 240,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/'),
                  child: const Text('押してね'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
