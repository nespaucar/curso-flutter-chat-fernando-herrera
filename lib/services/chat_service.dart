import 'dart:convert';

import 'package:chat_front/global/environment.dart';
import 'package:chat_front/models/mensaje.dart';
import 'package:chat_front/models/mensajes_response.dart';
import 'package:chat_front/models/usuario.dart';
import 'package:chat_front/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatService with ChangeNotifier {
  late Usuario usuarioPara;

  Future <List<Mensaje>> getChat(String? usuarioID) async {
    final uri = Uri.parse('${ Environment.apiUrl }/mensajes/$usuarioID');
    final resp = await http.post(uri,
      headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken()
      }
    );

    final mensajesResp = mensajesResponseFromJson(resp.body);
    return mensajesResp.mensajes;
  }
}