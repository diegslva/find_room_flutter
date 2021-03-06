import 'package:find_room/bloc/bloc_provider.dart';
import 'package:find_room/pages/home/home_page.dart';
import 'package:find_room/pages/login_register/login_page.dart';
import 'package:find_room/pages/saved/saved_page.dart';
import 'package:find_room/user_bloc/user_bloc.dart';
import 'package:find_room/user_bloc/user_login_state.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MyApp extends StatelessWidget {
  final appTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'SF-Pro-Text',
    primaryColorDark: const Color(0xff512DA8),
    primaryColorLight: const Color(0xffD1C4E9),
    primaryColor: const Color(0xff673AB7),
    accentColor: const Color(0xff00BCD4),
    dividerColor: const Color(0xffBDBDBD),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phòng trọ tốt',
      theme: appTheme,
      builder: (BuildContext context, Widget child) {
        return Scaffold(
          drawer: MyDrawer(
            navigator: child.key as GlobalKey<NavigatorState>,
          ),
          body: child,
        );
      },
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => MyHomePage(),
        '/saved': (context) => SavedPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}

class MyDrawer extends StatelessWidget {
  final GlobalKey<NavigatorState> navigator;

  const MyDrawer({Key key, this.navigator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);

    final DrawerControllerState drawerControllerState =
        context.rootAncestorStateOfType(TypeMatcher<DrawerControllerState>());

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildUserAccountsDrawerHeader(userBloc.userLoginState$, drawerControllerState),
          ListTile(
            title: Text('Trang chủ'),
            onTap: () {
              drawerControllerState.close();
              navigator.currentState.popUntil(ModalRoute.withName('/'));
            },
            leading: Icon(Icons.home),
          ),
          _buildSavedListTile(userBloc.userLoginState$, drawerControllerState),
          Divider(),
          _buildLoginLogoutButton(userBloc, drawerControllerState),
        ],
      ),
    );
  }

  Widget _buildSavedListTile(
    ValueObservable<UserLoginState> loginState$,
    DrawerControllerState drawerControllerState,
  ) {
    return StreamBuilder<UserLoginState>(
      stream: loginState$,
      initialData: loginState$.value,
      builder: (context, snapshot) {
        final loginState = snapshot.data;

        if (loginState is NotLogin) {
          return Container(
            width: 0,
            height: 0,
          );
        }

        if (loginState is UserLogin) {
          return ListTile(
            title: const Text('Đã lưu'),
            onTap: () {
              drawerControllerState.close();
              navigator.currentState.pushNamedAndRemoveUntil(
                '/saved',
                ModalRoute.withName('/'),
              );
            },
            leading: const Icon(Icons.bookmark),
          );
        }

        return Container(
          width: 0,
          height: 0,
        );
      },
    );
  }

  Widget _buildUserAccountsDrawerHeader(
    ValueObservable<UserLoginState> loginState$,
    DrawerControllerState drawerControllerState,
  ) {
    return StreamBuilder<UserLoginState>(
      stream: loginState$,
      initialData: loginState$.value,
      builder: (context, snapshot) {
        final loginState = snapshot.data;

        if (loginState is UserLogin) {
          return UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(loginState.avatar),
              backgroundColor: Colors.white,
            ),
            accountEmail: Text(loginState.email),
            accountName: Text(loginState.fullName),
          );
        }

        if (loginState is NotLogin) {
          return UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              child: const Icon(Icons.image),
            ),
            accountEmail: const Text('Đăng nhập ngay'),
            accountName: Container(),
            onDetailsPressed: () {
              drawerControllerState.close();
              navigator.currentState.pushNamedAndRemoveUntil(
                '/login',
                ModalRoute.withName('/'),
              );
            },
          );
        }

        return Container(width: 0, height: 0);
      },
    );
  }

  Widget _buildLoginLogoutButton(
    UserBloc userBloc,
    DrawerControllerState drawerControllerState,
  ) {
    return StreamBuilder<UserLoginState>(
      stream: userBloc.userLoginState$,
      initialData: userBloc.userLoginState$.value,
      builder: (context, snapshot) {
        final loginState = snapshot.data;

        if (loginState is NotLogin) {
          return ListTile(
            title: const Text('Đăng nhập'),
            onTap: () {
              drawerControllerState.close();
              navigator.currentState.pushNamedAndRemoveUntil(
                '/login',
                ModalRoute.withName('/'),
              );
            },
            leading: const Icon(Icons.person_add),
          );
        }

        if (loginState is UserLogin) {
          return ListTile(
            title: const Text('Đăng xuất'),
            onTap: () async {
              drawerControllerState.close();

              final bool signOut = await showDialog<bool>(
                context: navigator.currentState.overlay.context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn chắc chắn muốn đăng xuất'),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Hủy'),
                        onPressed: () => navigator.currentState.pop(false),
                      ),
                      FlatButton(
                        child: const Text('OK'),
                        onPressed: () => navigator.currentState.pop(true),
                      ),
                    ],
                  );
                },
              );

              if (signOut ?? false) {
                userBloc.signOut.add(null);
              }
            },
            leading: const Icon(Icons.exit_to_app),
          );
        }

        return Container(
          width: 0,
          height: 0,
        );
      },
    );
  }
}

class RootScaffold {
  RootScaffold._();

  static openDrawer(BuildContext context) {
    final ScaffoldState scaffoldState =
        context.rootAncestorStateOfType(TypeMatcher<ScaffoldState>());
    scaffoldState.openDrawer();
  }

  static ScaffoldState of(BuildContext context) {
    final ScaffoldState scaffoldState =
        context.rootAncestorStateOfType(TypeMatcher<ScaffoldState>());
    return scaffoldState;
  }
}
