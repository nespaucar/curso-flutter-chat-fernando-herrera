import 'package:chat_front/helpers/navegar_pagina.dart';
import 'package:chat_front/models/usuario.dart';
import 'package:chat_front/pages/chat_page.dart';
import 'package:chat_front/pages/login_page.dart';
import 'package:chat_front/services/auth_service.dart';
import 'package:chat_front/services/chat_service.dart';
import 'package:chat_front/services/socket_service.dart';
import 'package:chat_front/services/usuarios_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsuariosPage extends StatefulWidget {
  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  final usuariosService = UsuariosService();

  List<Usuario> usuarios = [
    //Usuario(online: true, email: 'test1@test.com', nombre: 'María', uid: '1'),
    //Usuario(online: false, email: 'test2@test.com', nombre: 'Melisa', uid: '2'),
    //Usuario(online: true, email: 'test3@test.com', nombre: 'Fernando', uid: '3')
  ];

  @override
  void initState() {
    this._cargarUsuarios();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    
    final usuario = authService.usuario;
    final String nombreUsuario = (usuario == null ? "" : usuario.nombre);

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(nombreUsuario, style: TextStyle(color: Colors.black54))),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.exit_to_app, color: Colors.black54),
          onPressed: () {
            // Desconectamos los sockets
            socketService.disconnect();
            navegarPagina(context, LoginPage());
            AuthService.deleteToken();
          },
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus==ServerStatus.Online) 
              ? Icon(Icons.check_circle, color: Colors.green) 
              : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () => _cargarUsuarios(),
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Icon(Icons.check, color: Colors.blue[400]),
          waterDropColor: Colors.blue,
        ),
        child: _listViewUsuarios(),
      ),
    );
  }

  ListView _listViewUsuarios() {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemBuilder: (_, i) => _usuarioListTile(usuarios[i]),
      separatorBuilder: (_, i) => Divider(),
      itemCount: usuarios.length
    );
  }

  ListTile _usuarioListTile(Usuario usuario) {
    return ListTile(
        title: Text(usuario.nombre),
        subtitle: Text(usuario.email),
        leading: CircleAvatar(
          child: Text(usuario.nombre.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        trailing: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: usuario.online ? Colors.green[300] : Colors.red,
            borderRadius: BorderRadius.circular(100)
          ),
        ),
        onTap: () {
          final chatService = Provider.of<ChatService>(context, listen: false);
          chatService.usuarioPara = usuario;
          Navigator.pushNamed(context, 'chat');
        },
      );
  }

  _cargarUsuarios() async {
    // monitor network fetch
    //await Future.delayed(Duration(milliseconds: 1000));   
    // Carcamos los usuarios del service
    this.usuarios = await usuariosService.getUsuarios();
    setState(() {});
    
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
