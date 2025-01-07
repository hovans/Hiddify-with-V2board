import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/router/routes.dart';
import 'package:hiddify/features/panel/xboard/services/auth_provider.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'app_router.g.dart';

bool _debugMobileRouter = false;

final useMobileRouter = !PlatformUtils.isDesktop || (kDebugMode && _debugMobileRouter);
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// TODO: test and improve handling of deep link
@riverpod
GoRouter router(RouterRef ref) {
  final notifier = ref.watch(routerListenableProvider.notifier);
  final isLoggedIn = ref.watch(authProvider); // 获取登录状态

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login', // 初始路由为 login
    debugLogDiagnostics: true,
    routes: [
      if (useMobileRouter) $mobileWrapperRoute else $desktopWrapperRoute,
      $loginRoute,
      $registerRoute,
      $forgetPasswordRoute,
    ],
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggingIn = state.uri.toString() == const LoginRoute().location;
      final isRegistering = state.uri.toString() == const RegisterRoute().location; // 检查注册路由
      final isForgettingPassword = state.uri.toString() == const ForgetPasswordRoute().location;

      if (!isLoggedIn && !isLoggingIn && !isRegistering && !isForgettingPassword) {
        // 如果用户已看过 IntroPage，但未登录且不在登录、注册页面，跳转到登录页面
        return const LoginRoute().location;
      }

      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        // 如果用户已登录且当前在登录页面或注册页面，则跳转到主页
        return const HomeRoute().location;
      }

      return null;
    },
    observers: [
      SentryNavigatorObserver(),
    ],
  );
}

final tabLocations = [
  const HomeRoute().location,
  const ProxiesRoute().location,
  const UserInfoRoute().location,
  const ConfigOptionsRoute().location,
  const SettingsRoute().location,
];

int getCurrentIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.path;
  if (location == const HomeRoute().location) return 0;
  var index = 0;
  for (final tab in tabLocations.sublist(1)) {
    index++;
    if (location.startsWith(tab)) return index;
  }
  return 0;
}

void switchTab(int index, BuildContext context) {
  assert(index >= 0 && index < tabLocations.length);
  final location = tabLocations[index];
  return context.go(location);
}

@riverpod
class RouterListenable extends _$RouterListenable with AppLogger implements Listenable {
  VoidCallback? _routerListener;

  @override
  Future<void> build() async {
    ref.listenSelf((_, __) {
      if (state.isLoading) return;
      loggy.debug("triggering listener");
      _routerListener?.call();
    });
  }

// ignore: avoid_build_context_in_providers
  String? redirect(BuildContext context, GoRouterState state) {
    return const HomeRoute().location;
  }

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    _routerListener = null;
  }
}
