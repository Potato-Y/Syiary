import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syiary_client/models/providers/user_info.dart';
import 'package:syiary_client/models/response/authenticate_model/user_model.dart';
import 'package:syiary_client/screens/group_screen.dart';
import 'package:syiary_client/screens/login_screen.dart';
import 'package:syiary_client/screens/signup_screen.dart';
import 'package:syiary_client/services/api_services.dart';
import 'package:syiary_client/widgets/logo_widget.dart';

void main(List<String> args) async {
  /// Android 플랫폼에서 상단 바를 투명하게 수정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,

      /// 안드로이드 플랫폼에서 네비게이션 바의 배경 색을 설정
      systemNavigationBarColor: Colors.white,
    ),
  );

  /// 앱 파일의 유요한 디렉터리로 Hive 초기화
  await Hive.initFlutter();

  await Hive.openBox('app');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => UserInfo(),
      )
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Syiary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const StartLoadScreen(),
          ),
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => LoginScreen(),
          ),
          // GoRoute(
          //   path: '/main',
          //   name: 'main',
          //   builder: (context, state) =>
          //       accountStatus ? const GroupScreen() : LoginScreen(),
          // ),
          GoRoute(
            path: '/signup',
            name: 'signup',
            builder: (context, state) => SignupScreen(),
          ),
          GoRoute(
            path: '/group',
            name: 'group',
            builder: (context, state) => const GroupScreen(),
          ),
        ],
      ),
    );
  }
}

/// 앱이 실행됨에 필요한 기본적인 정보들을 불러온다.
class StartLoadScreen extends StatelessWidget {
  const StartLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('app');
    bool accountStatus = false; // 계정 접근 상태를 나타냄

    // db애서 token 정보 가져오기
    String? accessToken = box.get('user_access_token');
    String? refreshToken = box.get('user_refresh_token');

    if (accessToken != null && refreshToken != null) {
      /// db에 token 정보가 있을 경우 계정 정보가 있으므로 status를 true로 변경한다.
      debugPrint('accessToken: $accessToken\nrefreshToken: $refreshToken');
      accountStatus = true;
    }

    return Scaffold(
      body: FutureBuilder(
        future: _load(),
        builder: (context, snapshot) {
          // 계정 정보가 없는 경우 login 페이지로 이동한다.
          if (accountStatus == false) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/login');
            });
          }

          // 받아온 데이터가 있는지 확인
          if (snapshot.hasData) {
            debugPrint('load screen data in.');
            if (snapshot.data == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Fluttertoast.showToast(msg: '로그인에 실패하였습니다.');
                context.go('/login');
              });
            }

            // 데이터가 정상적으로 들어왔다고 판단되면 데이터 저장 후 group 화면으로 이동
            UserModel user = snapshot.data!;

            if (context.mounted) {
              context.read<UserInfo>().setUserId = user.userId!;
              context.read<UserInfo>().setEmail = user.email!;
              context.read<UserInfo>().setNickName = user.nickname!;
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/group');
            });
          }

          // 로딩중 화면
          return Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: logo(),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<UserModel?> _load() async {
    try {
      UserModel user = await ApiService.getMyUserInfo();
      return user;
    } catch (e) {
      debugPrint('_load error\n$e');
      return null;
    }
  }
}
