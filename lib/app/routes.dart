import 'package:flutter/widgets.dart';

import '../presentation/counter/views/counter_page.dart';

abstract final class AppRoutes {
  static const String counter = '/';

  static Map<String, WidgetBuilder> get routes => {counter: (_) => const CounterPage()};
}
