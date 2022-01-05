import 'package:flutter/material.dart';

import 'package:chat_front/pages/chat_page.dart';
import 'package:chat_front/pages/loading_page.dart';
import 'package:chat_front/pages/login_page.dart';
import 'package:chat_front/pages/register_page.dart';
import 'package:chat_front/pages/usuarios_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'chat': ( _ ) => ChatPage(),
  'login': ( _ ) => LoginPage(),
  'register': ( _ ) => RegisterPage(),
  'usuarios': ( _ ) => UsuariosPage(),
  'loading': ( _ ) => LoadingPage(),
};