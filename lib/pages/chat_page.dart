import 'dart:io';

import 'package:chat_front/helpers/navegar_pagina.dart';
import 'package:chat_front/pages/usuarios_page.dart';
import 'package:chat_front/services/auth_service.dart';
import 'package:chat_front/services/chat_service.dart';
import 'package:chat_front/services/socket_service.dart';
import 'package:chat_front/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ChatPage extends StatefulWidget {

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {

  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  bool _estaEscribiendo = false;
  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;
  
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);

    // Escuchar mensajes
    this.socketService.socket.on('mensaje-persona', _escucharMensaje);
    super.initState();
  }

  void _escucharMensaje(dynamic payload) {
    ChatMessage message = ChatMessage(
      uid: payload['de'],
      texto: payload['mensaje'],
      animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 300)),
    );
    setState(() {
      this._messages.insert(0, message);
      // Actualizar el controlador para que se vean los cambios
      message.animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {    

    final usuarioPara = this.chatService.usuarioPara;
    final String nombreUsuario = (usuarioPara == null ? "" : usuarioPara.nombre);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Column(
            children: [
              CircleAvatar(
                child: Text(nombreUsuario.substring(0, 2), style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue[100],
                maxRadius: 14,
              ),
              SizedBox(height: 3),
              Text(nombreUsuario, style: TextStyle(color: Colors.black87, fontSize: 12))
            ],
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _messages[i],
                reverse: true,
              ),
            ),
            Divider(height: 1),
            Container(
              color: Colors.white,
              child: _inputChat(),
            )
          ],
        ),
      ),
   );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (String texto) {
                  setState(() {
                    if(texto.trim().length > 0) {
                      _estaEscribiendo = true;
                    } else {
                      _estaEscribiendo = false;
                    }
                  });
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Enviar Mensaje'
                ),
                focusNode: _focusNode,
              ),
            ),
            // Botón de Enviar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Platform.isIOS ? 
                CupertinoButton(
                  child: Text('Enviar'),
                  onPressed: () => _estaEscribiendo ? _handleSubmit(_textController.text.trim()) : null
                ) :
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  // El IconTheme es para que se deshabilite el botón cuando quieras enviar algo vacío
                  child: IconTheme(
                    data: IconThemeData(color: Colors.blue[400]),
                    child: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.send),
                      onPressed: () => _estaEscribiendo ? _handleSubmit(_textController.text.trim()) : null
                    ),
                  ),
                )

            )
          ],
        ),
      ),
    );
  }

  _handleSubmit (String texto) {
    // if(_textController.text.trim() != '') print(texto);
    _textController.clear();
    _focusNode.requestFocus();

    if(texto.trim() != '') {
      ChatMessage newMessage = ChatMessage(
        uid: '123',
        texto: texto,
        animationController: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 400)
        ),
      );
      _messages.insert(0, newMessage);
      newMessage.animationController.forward();

      // Envío mensaje al socket service
      socketService.emit('mensaje-personal', {
        'de': this.authService.usuario?.uid,
        'para': this.chatService.usuarioPara?.uid,
        'mensaje': texto.trim()
      });
    }  

    setState(() => _estaEscribiendo = false);    
  }

  @override
  void dispose() {
    // TODO: cerrar los sockets
    for(ChatMessage message in _messages) {
      // Cierro todas las animaciones
      message.animationController.dispose();
    }
    // Desconectar socket de mensajes
    this.socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}