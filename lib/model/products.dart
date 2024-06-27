import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsModel extends ChangeNotifier {
  // Cambia la URL a tu endpoint local
  static const String _url = "http://localhost:5126/api/Producto/";

  static List<Product> products = [
    Product(
      idProducto: 1,
      nombre: "Hola Mundo",
      categoriaDescription: "Marca reconocida",
      idCategoria: 1,
      precio: 3.0,
      stock: 99,
    )
  ];

  List<String> cathegories() => products
      .map((e) => e.categoriaDescription ?? "Otros")
      .toSet()
      .toList();

  Product getById(int id) => products.firstWhere((element) => element.idProducto == id);
  Product getByPos(int idx) => products[idx];
  List<Product> getByCathegoryName(String name) => products.where((e) => e.categoriaDescription == name).toList();
  int get count => products.length;
  bool loading = false;

  bool reduceStock(int id, int count) {
    var product = getById(id);
    if ((product.stock == null) || (product.stock! - count) < 0) {
      return false;
    }
    product.stock = product.stock == null ? 0 : product.stock! - count;
    notifyListeners();
    return true;
  }

  void addToStock(int id, int count) {
    var product = getById(id);
    product.stock = product.stock == null ? 0 : product.stock! + count;
    notifyListeners();
  }

  Future<List<Product>> _getData(context) async {
    late List<Product> data;
    try {
      final response = await http.get(
        Uri.parse("${_url}Lista"),
      );
      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        data = (item['value'] as List)
            .where((element) => element['stock'] != 0 && element['esActivo'] == 1)
            .map((e) => Product.fromJson(e))
            .toList();
      } else {
        debugPrint('Error Occurred');
        data = products;
      }
    } catch (e) {
      debugPrint('Error Occurred ${e.toString()}');
      data = products;
    }
    return data;
  }

  fetchProducts(context) async {
    loading = true;
    products = await _getData(context);
    loading = false;

    notifyListeners();
  }
}

class Product {
  // https://www.flaticon.com/free-icons/box" 
  // Box icons created by Freepik - Flaticon
  static const String _defaultPicture = "https://proyecto-mobiles.s3.us-east-2.amazonaws.com/open-box.png";

  int? idProducto;
  String? nombre;
  int? idCategoria;
  String? categoriaDescription;
  int? stock;
  num? precio;
  bool? esActivo;
  String? urlImagen = _defaultPicture;

  Product({
    this.idProducto,
    this.nombre,
    this.idCategoria,
    this.categoriaDescription,
    this.stock,
    this.precio,
    this.esActivo,
    this.urlImagen,
  });

  Product.fromJson(Map<String, dynamic> json) {
    idProducto = json['idProducto'];
    nombre = json['nombre'];
    idCategoria = json['idCategoria'];
    categoriaDescription = json['categoriaDescription'];
    stock = json['stock'];
    precio = num.parse(json['precio']);
    esActivo = json['esActivo'] == 0 ? false : true;
    urlImagen = (json['urlImagen'] == null || json['urlImagen'] == "") ? _defaultPicture : json['urlImagen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['idProducto'] = idProducto;
    data['nombre'] = nombre;
    data['idCategoria'] = idCategoria;
    data['categoriaDescription'] = categoriaDescription;
    data['stock'] = stock;
    data['precio'] = precio;
    data['esActivo'] = esActivo;
    data['urlImagen'] = urlImagen;
    return data;
  }
}
