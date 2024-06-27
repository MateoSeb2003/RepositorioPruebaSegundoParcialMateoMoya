import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:proyecto_final_movil/model/user.dart';
import 'package:proyecto_final_movil/util/http.dart';

class ProductOrderModel extends ChangeNotifier {
  static const String _urlProductOrder = "http://localhost:5126/api/Venta/";
  static final f = DateFormat('dd/MM/yyyy');

  late UserModel _user;

  set user(UserModel user) {
    _user = user;
  }

  static List<ProductOrder> orders = [];
  bool loading = false;

  ProductOrder getById(int id) => orders.firstWhere((element) => element.idVenta == id);
  ProductOrder getByPos(int idx) => orders[idx];
  int get count => orders.length;

  Future<List<ProductOrder>> _getData(context) async {
    late List<ProductOrder> data;
    var fechaFin = f.format(DateTime.now());
    var fechaInicio = f.format(DateTime.now().subtract(const Duration(days: 365)));
    try {
      final response = await http.get(
        Uri.parse("${_urlProductOrder}Historial?buscarPor=fecha&fechaInicio=$fechaInicio&fechaFin=$fechaFin"),
        headers: contentTypeHeader(_user.token!),
      );
      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        data = (item["value"] as List)
            .map((e) => ProductOrder.fromJson(e))
            .toList();
      } else {
        debugPrint('Error Occurred while getting orders ${response.body}');
        data = orders;
      }
    } catch (e) {
      debugPrint('Error Occurred ${e.toString()}');
      data = orders;
    }
    return data;
  }

  fetchOrders(context) async {
    loading = true;
    orders = await _getData(context);
    loading = false;

    notifyListeners();
  }

  Future<bool> postOrder(ProductOrder order) async {
    try {
      final response = await http.post(
        Uri.parse("${_urlProductOrder}Registrar"),
        headers: contentTypeHeader(_user.token ?? ""),
        body: json.encode(order.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      }

      debugPrint('Error Occurred on post order: ${response.body}');
      return false;

    } catch (e) {
      debugPrint('Error Occurred on get user: ${e.toString()}');
      return false;
    }
  }
}

class ProductOrder {
  static final _f = DateFormat('dd/MM/yyyy');

  int? idVenta = 0;
  String? numeroDocumento;
  final String tipoPago = "Tarjeta";
  num? total;
  DateTime? fechaRegistro = DateTime.now();
  Map<String, dynamic>? cliente;
  List<OrderDetail>? detalleVenta;

  ProductOrder({
    this.idVenta = 0,
    this.numeroDocumento,
    this.total,
    this.fechaRegistro,
    this.cliente,
    this.detalleVenta,
  });

  Map<String, dynamic> toJson() {
    return {
      "idVenta": idVenta,
      "numeroDocumento": numeroDocumento,
      "tipoPago": tipoPago,
      "totalTexto": total.toString(),
      "cliente": cliente,
      "fechaRegistro": fechaRegistro,
      "detalleVenta": detalleVenta?.map((e) => e.toJson()).toList()
    };
  }

  ProductOrder.fromJson(Map<String, dynamic> data) {
    idVenta = data['idVenta'];
    numeroDocumento = data['numeroDocumento'];
    total = num.parse(data['totalTexto']);
    fechaRegistro = _f.parse(data['fechaRegistro']);
    cliente = data['cliente'];
    detalleVenta = (data['detalleVenta'] as List).map((e) => OrderDetail.fromJson(e)).toList();
  }
}

class OrderDetail {
  int? idProducto;
  String? productoDescription;
  int? cantidad;
  num? precio;
  num? total;

  OrderDetail({
    this.idProducto,
    this.cantidad,
    this.precio,
    this.total
  });

  Map<String, dynamic> toJson() {
    return {
      "idProducto": idProducto,
      "productoDescription": productoDescription,
      "cantidad": cantidad,
      "precioTexto": precio.toString(),
      "totalTexto": total.toString(),
    };
  }

  OrderDetail.fromJson(Map<String, dynamic> data) {
    idProducto = data["idProducto"];
    productoDescription = data["productoDescription"];
    cantidad = data["cantidad"];
    precio = num.parse(data["precioTexto"]);
    total = num.parse(data["totalTexto"]);
  }
}
