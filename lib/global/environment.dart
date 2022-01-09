import 'dart:io';

class Environment {
  static String ip = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  static String puerto = '3000';
  static String socketUrl = 'http://'+ip+':'+puerto;
  static String apiUrl    = socketUrl+'/api';  
}