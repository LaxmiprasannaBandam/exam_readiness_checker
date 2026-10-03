import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// Makes [AppState] available to every widget below it.
///
/// Usage inside any widget:
///   final state = AppScope.of(context);    // rebuilds when data changes
///   final state = AppScope.read(context);  // does NOT rebuild (use in
///                                          // initState / button handlers)
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found above this widget');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found above this widget');
    return scope!.notifier!;
  }
}
