import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Startpage extends StatelessWidget {
  const Startpage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
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
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  /*
                  mainAxisSize: MainAxisSize.min, // 中央寄せ
                  children: [
                    const Text(
                      'スタートページ', //一番最初のページ，もらったと作ったのページ
                      style: TextStyle(
                        fontSize: 24, // 文字サイズ
                        fontWeight: FontWeight.bold, // 太字
                      ),
                    ),
                    const SizedBox(height: 20), // 文字とボタンの間隔
                    ElevatedButton(
                      onPressed: () {
                        context.push('/photo');
                        debugPrint('ボタンが押されました');
                      },
                      child: const Text('押してね'),
                    ),
                  ],
                  */
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        context.push('/photo');
                        debugPrint('ボタンが押されました');
                      },
                      child: Container(
                          width: 172,
                          height: 259,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFFF92929),
                              width: 5.0,
                            ),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              size: 100,
                              color: Color(0xFFF92929),
                            ),
                          )),
                    ),
                    Container(
                      width: 172,
                      height: 259,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xFFF92929),
                          width: 5.0,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Text('あ'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
