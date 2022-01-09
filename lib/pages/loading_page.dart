import 'package:chat_front/helpers/navegar_pagina.dart';
import 'package:chat_front/pages/usuarios_page.dart';
import 'package:chat_front/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';


class LoadingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkLoginState(context),
        builder: (context, snapshot) {
          return Center(
            child: Text('Espere...'),
          );
        }
      ),
   );
  }

  Future checkLoginState(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final autenticado = await authService.isLoggedIn();

    if (autenticado) {
      // TODO: conectar al socket server

      // Navigator.pushReplacementNamed(context, 'usuarios');
      navegarPagina(context, UsuariosPage());
    } else {
      navegarPagina(context, LoginPage());
    }
  }
}