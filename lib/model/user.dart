import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserModel extends ChangeNotifier {
  // Cambia las URL a tus endpoints locales
  static const String _urlUsers = "http://localhost:5126/api/Usuario/";
  static const String _urlClientes = "http://localhost:5126/api/Cliente/";

  late SharedPreferences _prefs;
  static const String _tokenKey = 'token';
  static const String _uidKey = 'app_uid';
  static const String _namesKey = 'app_unames';
  static const String _cidKey = 'app_cid';
  static const String _actionsKey = 'actions';

  List<UserAction> _actions = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadActions();
  }

  String? get token => _prefs.getString(_tokenKey);
  int? get userId => _prefs.getInt(_uidKey);
  String? get userNames => _prefs.getString(_namesKey);
  String? get userCid => _prefs.getString(_cidKey);
  List<UserAction> get actions => _actions;

  Future<bool> login(LoginDTO login) async {
    try {
      final response = await http.post(
        Uri.parse("${_urlUsers}IniciarSesion"),
        headers: contentTypeHeader(token ?? ""),
        body: jsonEncode({
          'Correo': login.correo,
          'Clave': login.clave,
        }),
      );
      if (response.statusCode == 200) {
        final user =
            (json.decode(response.body)["value"] as Map<String, dynamic>);
        setNames(user["nombreCompleto"]);
        setUid(user["idUsuario"]);
        setToken(user["token"]);
        setCid(user["cedulaCliente"]);
        _recordAction('Inicio de sesión', 'Login');
        return true;
      }
      debugPrint('Error Occurred on login: ${response.body}');
    } catch (e) {
      debugPrint('Error Occurred on login: ${e.toString()}');
    }
    return false;
  }

  Future<bool> setToken(String token) async {
    var saved = await _prefs.setString(_tokenKey, token);
    notifyListeners();
    return saved;
  }

  Future<bool> setCid(String cid) async {
    var saved = await _prefs.setString(_cidKey, cid);
    notifyListeners();
    return saved;
  }

  Future<bool> setNames(String names) async {
    var saved = await _prefs.setString(_namesKey, names);
    notifyListeners();
    return saved;
  }

  Future<bool> setUid(int uid) async {
    var saved = await _prefs.setInt(_uidKey, uid);
    notifyListeners();
    return saved;
  }

  void clearAll() {
    _prefs.clear();
    _actions.clear();
    notifyListeners();
  }

  Future<User?> getUserWithClient(String cid) async {
    try {
      final response = await http.get(
        Uri.parse("${_urlClientes}Lista"),
        headers: contentTypeHeader(token ?? ""),
      );

      if (response.statusCode == 200) {
        final responseUsr = await http.get(
          Uri.parse("${_urlUsers}Lista"),
          headers: contentTypeHeader(token ?? ""),
        );

        User? usr;
        if (responseUsr.statusCode == 200) {
          final item = json.decode(responseUsr.body);
          usr = (item['value'] as List)
              .where((element) => element['idUsuario'] == userId)
              .map((e) => User.fromJson(e))
              .firstOrNull;
        }

        final item = json.decode(response.body);
        var client = (item['value'] as List)
            .where((element) => element['cedulaCliente'] == cid)
            .map((e) => User.fromJson(e))
            .firstOrNull;

        if (client == null) {
          return null;
        }

        client.idUsuario = usr?.idUsuario ?? 0;
        client.clave = usr?.clave ?? "";
        _recordAction('Obtuvo información de usuario para $cid', 'Fetch');
        return client;
      }
      debugPrint('Error Occurred on get user: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error Occurred on get user: ${e.toString()}');
      return null;
    }
  }

  Future<bool> postUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse("${_urlClientes}Guardar"),
        headers: contentTypeHeader(token ?? ""),
        body: jsonEncode({
          "cedulaCliente": user.cedulaCliente,
          "nombreCompleto": user.nombreCompleto,
          "correo": user.correo,
          "direccion": user.direccion,
        }),
      );

      if (response.statusCode == 200) {
        final response = await http.post(
          Uri.parse("${_urlUsers}Guardar"),
          headers: contentTypeHeader(token ?? ""),
          body: jsonEncode({
            "idUsuario": 0,
            "nombreCompleto": user.nombreCompleto,
            "correo": user.correo,
            "idRol": user.idRol,
            "rolDescripcion": "Cliente",
            "clave": user.clave,
            "esActivo": user.esActivo,
            "cedulaCliente": user.cedulaCliente,
          }),
        );

        if (response.statusCode == 200) {
          _recordAction('Creó usuario ${user.nombreCompleto}', 'Insert');
          return true;
        }
      }
      debugPrint('Error Occurred on Create user: ${response.body}');
    } catch (e) {
      debugPrint('Error Occurred on Create user: ${e.toString()}');
    }
    return false;
  }

  Future<bool> putUser(User user) async {
    try {
      final response = await http.put(
        Uri.parse("${_urlClientes}Editar"),
        headers: contentTypeHeader(token ?? ""),
        body: jsonEncode({
          "cedulaCliente": user.cedulaCliente,
          "nombreCompleto": user.nombreCompleto,
          "correo": user.correo,
          "direccion": user.direccion,
        }),
      );

      if (response.statusCode == 200) {
        var body = {
          "idUsuario": user.idUsuario,
          "nombreCompleto": user.nombreCompleto,
          "correo": user.correo,
          "idRol": user.idRol,
          "rolDescripcion": "Cliente",
          "clave": user.clave,
          "esActivo": user.esActivo,
          "cedulaCliente": user.cedulaCliente,
        };

        final response = await http.put(
          Uri.parse("${_urlUsers}Editar"),
          headers: contentTypeHeader(token ?? ""),
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          _recordAction('Actualizó usuario ${user.nombreCompleto}', 'Update');
          return true;
        }
        debugPrint('Error Occurred on Put user: ${response.statusCode}');
      }
      debugPrint('Error Occurred on Put client: ${response.body}');
    } catch (e) {
      debugPrint('Error Occurred on Put user: ${e.toString()}');
    }
    return false;
  }

  void _recordAction(String action, String actionType) {
    final userAction = UserAction(action, DateTime.now(), actionType);
    _actions.add(userAction);
    _saveActions();
  }

  void _saveActions() {
    List<String> actions =
        _actions.map((action) => jsonEncode(action.toJson())).toList();
    _prefs.setStringList(_actionsKey, actions);
  }

  void _loadActions() {
    List<String>? actions = _prefs.getStringList(_actionsKey);
    if (actions != null) {
      _actions = actions
          .map((action) => UserAction.fromJson(jsonDecode(action)))
          .toList();
    }
  }

  Map<String, String> contentTypeHeader(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

class UserAction {
  final String action;
  final DateTime timestamp;
  final String actionType;

  UserAction(this.action, this.timestamp, this.actionType);

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'actionType': actionType,
    };
  }

  factory UserAction.fromJson(Map<String, dynamic> json) {
    return UserAction(
      json['action'],
      DateTime.parse(json['timestamp']),
      json['actionType'],
    );
  }
}

class LoginDTO {
  LoginDTO({this.correo = "", this.clave = ""});
  String correo;
  String clave;
}

class User {
  User({
    this.cedulaCliente = "",
    this.nombreCompleto = "",
    this.correo = "",
    this.direccion = "",
    this.clave = "",
    this.fotoPerfil,
  });

  final int idRol = 4;
  final int esActivo = 1;

  int? idUsuario = 0;
  String? cedulaCliente;
  String? nombreCompleto;
  String? correo;
  String? rolDescripcion;
  String? direccion;
  String? clave;
  String? fotoPerfil;

  User.fromJson(Map<String, dynamic> json) {
    idUsuario = json["idUsuario"];
    cedulaCliente = json["cedulaCliente"];
    nombreCompleto = json["nombreCompleto"];
    correo = json["correo"];
    direccion = json["direccion"];
    rolDescripcion = json["rolDescripcion"];
    clave = json["clave"];
    fotoPerfil = json['fotoPerfil'];
  }
}
