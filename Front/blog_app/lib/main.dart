// Archivo: main.dart (MODIFICADO)
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- NUEVA IMPORTACIÓN
import 'package:blog_app/screens/posts/posts_screen.dart';
import 'screens/comments/comments_screen.dart';
import 'screens/comments/create_comment_screen.dart';
import 'screens/comments/comment_detail_screen.dart';
import 'screens/users/users_screen.dart';
import 'screens/users/create_user_screen.dart';
import 'screens/home_screen.dart';


Future<void> main() async { // <--- FUNCIÓN ASÍNCRONA
  // Asegura que Flutter esté inicializado antes de cargar el .env
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Carga el archivo .env
  try {
    await dotenv.load(fileName: ".env");
    // print('Variables de entorno cargadas.'); // Debug
  } catch (e) {
    // print('Error al cargar .env: $e'); // Manejo de error
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // El resto de la clase MyApp se mantiene igual.
    return MaterialApp(
      title: 'Flutter Flask App',
      home: HomeScreen(),
      routes: {
        '/users': (context) => UsersScreen(),
        '/createUser': (context) => CreateUserScreen(),
         '/posts': (context) => PostsScreen(),
        '/comments': (context) => CommentsScreen(),
        '/createComment': (context) => CreateCommentScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/commentDetail') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args.containsKey('commentId')) {
            return MaterialPageRoute(
              builder: (context) => CommentDetailScreen(commentId: args['commentId'] ?? ''),
            );
          }
        }
        return null;
      },
    );
  }
}