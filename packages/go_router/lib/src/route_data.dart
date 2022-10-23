// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

import 'route.dart';
import 'state.dart';

/// {@template route_data}
/// A superclass for each route data
/// {@endtemplate}
abstract class RouteData {
  /// {@macro route_data}
  const RouteData();

  /// [navigatorKey] is used to point to a certain navigator
  /// or pass it into the shell route
  ///
  /// In case of [ShellRoute] it will instantiate a new navigator
  /// with the given key
  ///
  /// In case of [GoRoute] it will use the given key to find the navigator
  GlobalKey<NavigatorState>? get navigatorKey => null;
}

/// Baseclass for supporting
/// [typed routing](https://gorouter.dev/typed-routing).
///
/// Subclasses must override one of [build], [buildPageWithState], or
/// [redirect].
abstract class GoRouteData extends RouteData {
  /// Allows subclasses to have `const` constructors.
  ///
  /// [GoRouteData] is abstract and cannot be instantiated directly.
  const GoRouteData();

  /// Creates the [Widget] for `this` route.
  ///
  /// Subclasses must override one of [build], [buildPageWithState], or
  /// [redirect].
  ///
  /// Corresponds to [GoRoute.builder].
  Widget build(BuildContext context) => throw UnimplementedError(
        'One of `build` or `buildPageWithState` must be implemented.',
      );

  /// A page builder for this route.
  ///
  /// Subclasses can override this function to provide a custom [Page].
  ///
  /// Subclasses must override one of [build], [buildPageWithState] or
  /// [redirect].
  ///
  /// Corresponds to [GoRoute.pageBuilder].
  ///
  /// By default, returns a [Page] instance that is ignored, causing a default
  /// [Page] implementation to be used with the results of [build].
  @Deprecated(
    'This method has been deprecated in favor of buildPageWithState. '
    'This feature was deprecated after v4.3.0.',
  )
  Page<void> buildPage(BuildContext context) => const NoOpPage();

  /// A page builder for this route with [GoRouterState].
  ///
  /// Subclasses can override this function to provide a custom [Page].
  ///
  /// Subclasses must override one of [build], [buildPageWithState] or
  /// [redirect].
  ///
  /// Corresponds to [GoRoute.pageBuilder].
  ///
  /// By default, returns a [Page] instance that is ignored, causing a default
  /// [Page] implementation to be used with the results of [build].
  Page<void> buildPageWithState(BuildContext context, GoRouterState state) =>
      // ignore: deprecated_member_use_from_same_package
      buildPage(context);

  /// An optional redirect function for this route.
  ///
  /// Subclasses must override one of [build], [buildPageWithState], or
  /// [redirect].
  ///
  /// Corresponds to [GoRoute.redirect].
  FutureOr<String?> redirect() => null;

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static String $location(String path, {Map<String, String>? queryParams}) =>
      Uri.parse(path)
          .replace(
            queryParameters:
                // Avoid `?` in generated location if `queryParams` is empty
                queryParams?.isNotEmpty ?? false ? queryParams : null,
          )
          .toString();

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static GoRoute $route<T extends GoRouteData>({
    required String path,
    required T Function(GoRouterState) factory,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
  }) {
    T factoryImpl(GoRouterState state) {
      final Object? extra = state.extra;

      // If the "extra" value is of type `T` then we know it's the source
      // instance of `GoRouteData`, so it doesn't need to be recreated.
      if (extra is T) {
        return extra;
      }

      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    Widget builder(BuildContext context, GoRouterState state) =>
        factoryImpl(state).build(context);

    Page<void> pageBuilder(BuildContext context, GoRouterState state) =>
        factoryImpl(state).buildPageWithState(context, state);

    FutureOr<String?> redirect(BuildContext context, GoRouterState state) =>
        factoryImpl(state).redirect();

    return GoRoute(
      path: path,
      builder: builder,
      pageBuilder: pageBuilder,
      redirect: redirect,
      routes: routes,
      parentNavigatorKey: parentNavigatorKey,
    );
  }

  /// Used to cache [GoRouteData] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<GoRouteData> _stateObjectExpando = Expando<GoRouteData>(
    'GoRouteState to GoRouteData expando',
  );
}

/// {@template shell_route_data}
/// Baseclass for supporting
/// [nested navigation](https://pub.dev/packages/go_router#nested-navigation)
/// {@endtemplate}
abstract class ShellRouteData extends RouteData {
  /// {@macro shell_route_data}
  const ShellRouteData();

  /// [pageBuilder] is used to build the page
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) =>
      const NoOpPage();

  /// [pageBuilder] is used to build the page
  Widget builder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) =>
      throw UnimplementedError(
        'One of `builder` or `pageBuilder` must be implemented.',
      );

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static ShellRoute $route<T extends ShellRouteData>({
    required String path,
    required T Function(GoRouterState) factory,
    GlobalKey<NavigatorState>? navigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
  }) {
    T factoryImpl(GoRouterState state) {
      final Object? extra = state.extra;

      // If the "extra" value is of type `T` then we know it's the source
      // instance of `GoRouteData`, so it doesn't need to be recreated.
      if (extra is T) {
        return extra;
      }

      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    Widget builder(
      BuildContext context,
      GoRouterState state,
      Widget navigator,
    ) =>
        factoryImpl(state).builder(
          context,
          state,
          navigator,
        );

    Page<void> pageBuilder(
      BuildContext context,
      GoRouterState state,
      Widget navigator,
    ) =>
        factoryImpl(state).pageBuilder(
          context,
          state,
          navigator,
        );

    return ShellRoute(
      builder: builder,
      pageBuilder: pageBuilder,
      routes: routes,
      navigatorKey: navigatorKey,
    );
  }

  /// Used to cache [ShellRouteData] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<ShellRouteData> _stateObjectExpando =
      Expando<ShellRouteData>(
    'GoRouteState to ShellRouteData expando',
  );
}

/// {@template typed_route}
/// A superclass for each typed route descendant
/// {@endtemplate}
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedRoute<T extends RouteData> {
  /// {@macro typed_route}
  const TypedRoute._({
    this.routes = const <TypedRoute<RouteData>>[],
    this.path,
  });

  /// Instantiate a [TypedRoute] with a [path] and [routes].
  factory TypedRoute.go({
    required String path,
    List<TypedRoute<RouteData>> routes = const <TypedRoute<RouteData>>[],
  }) =>
      TypedRoute<T>._(routes: routes, path: path);

  /// Instantiate a [TypedRoute] with [routes].
  factory TypedRoute.shell({
    List<TypedRoute<RouteData>> routes = const <TypedRoute<RouteData>>[],
  }) =>
      TypedRoute<T>._(routes: routes);

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedRoute<RouteData>> routes;

  /// The path that corresponds to this route.
  ///
  /// See [GoRoute.path].
  ///
  ///
  final String? path;
}

/// Internal class used to signal that the default page behavior should be used.
@internal
class NoOpPage extends Page<void> {
  /// Creates an instance of NoOpPage;
  const NoOpPage();

  @override
  Route<void> createRoute(BuildContext context) =>
      throw UnsupportedError('Should never be called');
}
