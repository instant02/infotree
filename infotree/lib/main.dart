import 'package:flutter/material.dart';
import 'package:infotree/model/theme/theme.dart';
import 'view/pages/root_page.dart';
import 'package:provider/provider.dart';
import 'view/pages/subscribe_page.dart';
import 'package:infotree/model/data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Data(),
      child: MaterialApp(
        theme: appTheme,
        title: 'Flutter Route Demo',
        initialRoute: '/root',
        routes: {
          '/subscribe': (context) => SubscribePage(),
          '/root': (context) => RootPage(),
        },
      ),
    );
  }
}
