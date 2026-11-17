import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'screens/login_screen.dart';

void
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(
    const WinnersApp(),
  );
}

class WinnersApp
    extends
        StatelessWidget {
  const WinnersApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Winners Supermarket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}
