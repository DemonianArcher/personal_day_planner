import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';
import 'calendar_system.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) => ThemeProvider());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme.themeData,
      darkTheme: theme.themeData,
      themeMode: theme.themeMode,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Day Planner'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: UpcomingEventsWidget(),
      ),
    );
  }
}
