import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/post_list_screen.dart';
import 'providers/post_provider.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProxyProvider<ApiService, PostProvider>(
          create: (context) => PostProvider(context.read<ApiService>()),
          update: (context, apiService, previousProvider) =>
              PostProvider(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Blog App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PostListScreen(),
      ),
    );
  }
}