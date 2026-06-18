import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  static const String appHost = 'www.ramiro-di-rico.dev';
  static const String customScheme = 'homemanagementapp';

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  GoRouter? _router;
  bool _initialLinkHandled = false;

  void attachRouter(GoRouter router) {
    _router = router;
    _subscription ??= _appLinks.uriLinkStream.listen(_handleUri);
    _handleInitialLink();
  }

  Future<void> _handleInitialLink() async {
    if (_initialLinkHandled) {
      return;
    }

    _initialLinkHandled = true;

    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleUri(uri);
      }
    } catch (_) {
      // Ignore malformed startup links and continue normal launch.
    }
  }

  void _handleUri(Uri uri) {
    final route = mapUriToRoute(uri);
    if (route == null || _router == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router?.go(route);
    });
  }

  String? mapLinkToRoute(String link) {
    final parsedUri = Uri.tryParse(link.trim());
    if (parsedUri == null) {
      return null;
    }

    return mapUriToRoute(parsedUri);
  }

  String? mapUriToRoute(Uri uri) {
    final segments = <String>[];

    if (uri.scheme == 'https' || uri.scheme == 'http') {
      if (uri.host != appHost) {
        return null;
      }

      segments.addAll(uri.pathSegments);
    } else if (uri.scheme == customScheme) {
      if (uri.host.isNotEmpty) {
        segments.add(uri.host);
      }
      segments.addAll(uri.pathSegments);
    } else {
      return null;
    }

    if (segments.length < 3) {
      return null;
    }

    if (segments[0] != 'public' || segments[1] != 'invites') {
      return null;
    }

    final token = segments[2];
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$',
    ).hasMatch(token);

    if (!isUuid) {
      return null;
    }

    return '/public/invites/$token';
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
