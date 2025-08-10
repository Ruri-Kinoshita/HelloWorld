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
                        image: DecorationImage(
                          image: AssetImage('images/example1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              /* ElevatedButton(
                onPressed: () {
                  context.push('/photo');
                  //context.push('/camera-off'); // カメラオフページに遷移
                  debugPrint('ボタンが押されました');
                },
                child: const Text('押してね'),
              ),*/
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Container(
                      width: 172,
                      height: 259,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/example2.png'),
                          fit: BoxFit.cover,
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
