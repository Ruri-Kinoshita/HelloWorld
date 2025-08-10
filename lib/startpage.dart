// startpage.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:helloworld/providers/received_images_provider.dart';

class Startpage extends StatelessWidget {
  const Startpage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFDEDADA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFFFFF),
            centerTitle: true,
            title: const Text('Hello World'),
            bottom: const TabBar(
              indicatorColor: Color(0xFF333333),
              labelColor: Color(0xFF333333),
              tabs: [Tab(text: 'つくる'), Tab(text: 'もらった')],
            ),
          ),
          body: TabBarView(
            children: [
              // --- つくる ---
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        context.push('/camera-off');
                        debugPrint('ボタンが押されました');
                      },
                      child: DottedBorder(
                        options: RectDottedBorderOptions(
                          dashPattern: [8, 4],
                          strokeWidth: 5,
                          //padding: EdgeInsets.all(16),
                          color: Color(0xFFF92929),
                        ),
                        child: Container(
                          width: 172,
                          height: 259,
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            size: 100,
                            color: Color(0xFFF92929),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: Image.asset('images/example1.png'),
                          ),
                        );
                      },
                      child: Container(
                        width: 172,
                        height: 259,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/example1.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- もらった（画像を大きく表示・タイトル/日付なし） ---
              Consumer(
                builder: (context, ref, _) {
                  final items = ref.watch(receivedImagesProvider);

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 48),
                          const SizedBox(height: 12),
                          const Text('まだ受け取った画像はありません'),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              context.push('/receive');
                            },
                            icon: const Icon(Icons.link),
                            label: const Text('リンクから受け取る'),
                          ),
                        ],
                      ),
                    );
                  }

                  // できるだけ大きく見せる：基本1列グリッド
                  // （必要なら下のcrossAxisCountを画面幅で2に切替などしてOK）
                  // final columns = MediaQuery.of(context).size.width >= 700 ? 2 : 1;
                  const columns = 2;

                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        // 作成したカードは縦長想定なので 3/4 を目安に
                        childAspectRatio: 3 / 4,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return GestureDetector(
                          onTap: () {
                            // タップで個別表示（任意）
                            context.push(
                              '/receive?imagename=${Uri.encodeComponent(item.imageName)}',
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.white,
                              child: Image.network(
                                item.downloadUrl,
                                fit: BoxFit.contain, // 画像を切り抜かずそのまま大きく
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                                loadingBuilder: (c, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
