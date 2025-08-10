import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';

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
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        // context.push('/photo');
                        context.push('/camera-off'); // カメラオフページに遷移
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
                    Container(
                      width: 172,
                      height: 259,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/example1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: Image.asset('images/example2.png'),
                          ),
                        );
                      },
                      child: Container(
                        width: 172,
                        height: 259,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/example2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
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
