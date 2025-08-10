import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helloworld/create.dart';
import 'package:helloworld/Role.dart';
import 'package:helloworld/Share.dart';
import 'package:helloworld/camera_off.dart';
import 'package:helloworld/photo.dart';
import 'package:helloworld/photo.dart';
import 'package:helloworld/receive.dart';
import 'package:helloworld/startpage.dart';

final goRouter = GoRouter(
  // アプリが起動した時
  initialLocation: '/',
  // パスと画面の組み合わせ
  routes: [
    GoRoute(
      path: '/',
      name: 'startpage',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: Startpage(),
        );
      },
    ),
    GoRoute(
      path: '/photo',
      name: 'photo',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const PhotoPage(),
        );
      },
    ),
    GoRoute(
      path: '/role',
      name: 'SelectRolePage',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const SelectRolePage(),
        );
      },
    ),
    GoRoute(
      path: '/create',
      name: 'CreatePage',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const Createpage(),
        );
      },
    ),
    GoRoute(
      path: '/share',
      name: 'SharePage',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const Sharepage(),
        );
      },
    ),
    GoRoute(
      path: '/receive',
      name: 'receivepage',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const ReceivePage(),
        );
      },
    ),
    GoRoute(
      path: '/camera-off',
      name: 'CameraOffPage',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const CameraOffPage(),
        );
      },
    ),
  ],
);
