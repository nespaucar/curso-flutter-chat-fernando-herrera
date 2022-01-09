import 'package:chat_front/helpers/mostrar_alerta.dart';
import 'package:chat_front/helpers/navegar_pagina.dart';
import 'package:chat_front/pages/login_page.dart';
import 'package:chat_front/pages/usuarios_page.dart';
import 'package:chat_front/services/auth_service.dart';
import 'package:chat_front/services/socket_service.dart';
import 'package:chat_front/widgets/boton_azul.dart';
import 'package:flutter/material.dart';

import 'package:chat_front/widgets/custom_input.dart';
import 'package:chat_front/widgets/labels.dart';
import 'package:chat_front/widgets/logo.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {

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
                  titulo: 'Registrar',
                ),
                _Form(),
                Labels(
                  ruta: LoginPage(),
                  titulo: 'Ya tengo una',
                  subtitulo: 'Regresar al Login'
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
  final nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);

    bool verificarCamposNoNulos() {
      bool camposLlenos = false;
      if(emailCtrl.text.toString()!=''&&
      passCtrl.text.toString()!=''&&
      nameCtrl.text.toString()!='') {
        camposLlenos = true;
      }
      return camposLlenos;
    }

    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.perm_identity,
            placeholder: 'Nombre',
            textController: nameCtrl
          ),
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
            text: 'Crear Cuenta',
            onPressed: authService.autenticando && verificarCamposNoNulos() ? null : () async {
              print(nameCtrl.text);
              print(emailCtrl.text);
              print(passCtrl.text);
              final registroOk = await authService.register(
                nameCtrl.text.trim(),
                emailCtrl.text.trim(),
                passCtrl.text.trim()
              );
              if(registroOk == true) {
                // Conectamos el servidor de sockets
                socketService.connect();
                navegarPagina(context, UsuariosPage());
              } else {
                mostrarAlerta(context, 'Registro incorrecto', registroOk.toString());
              }
            }
          )
        ]
      ),
    );
  }
}