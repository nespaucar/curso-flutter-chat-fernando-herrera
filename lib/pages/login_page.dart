import 'package:chat_front/helpers/mostrar_alerta.dart';
import 'package:chat_front/helpers/navegar_pagina.dart';
import 'package:chat_front/pages/register_page.dart';
import 'package:chat_front/pages/usuarios_page.dart';
import 'package:chat_front/services/auth_service.dart';
import 'package:chat_front/services/socket_service.dart';
import 'package:chat_front/widgets/boton_azul.dart';
import 'package:flutter/material.dart';

import 'package:chat_front/widgets/custom_input.dart';
import 'package:chat_front/widgets/labels.dart';
import 'package:chat_front/widgets/logo.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height*0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Logo(
                  titulo: 'Messenger',
                ),
                _Form(),
                Labels(
                  ruta: RegisterPage(),
                  titulo: '¿No tienes cuenta?',
                  subtitulo: 'Crea una ahora!'
                ),
                Container(
                  child: Text('Términos y condiciones de uso', style: TextStyle(fontWeight: FontWeight.w200),)
                )
              ],
            ),
          ),
        ),
      )
   );
  }
}

class _Form extends StatefulWidget {

  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);

    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            textController: passCtrl,
            isPassword: true,
          ),
          BotonAzul(
            text: 'Ingresar',
            onPressed: authService.autenticando ? null : () async {
              print(emailCtrl.text);
              print(passCtrl.text);
              FocusScope.of(context).unfocus();
              final loginOk = await authService.login(emailCtrl.text.trim(), passCtrl.text.trim());
              if(loginOk) {
                // Empezamos los sockets
                socketService.connect();
                navegarPagina(context, UsuariosPage());
              } else {
                mostrarAlerta(context, 'Login Incorrecto', 'Revisa tus credenciales nuevamente');
              }
            }
          )
        ]
      ),
    );
  }
}