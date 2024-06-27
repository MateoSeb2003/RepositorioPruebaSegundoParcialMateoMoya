import 'package:proyecto_final_movil/model/products.dart';
import 'package:flutter/material.dart';

class ShoppingCartModel extends ChangeNotifier {

  late ProductsModel _products;

  final List<SavedItem> _savedItems = <SavedItem>[];
  int get count => _savedItems.length;
  bool contains(int value) => _savedItems.any((element) => element.productId == value);

  Product getById(int id) => items.firstWhere((element) => element.idProducto == id);
  SavedItem? getSavedById(int id) => _savedItems.where((element) => element.productId == id).firstOrNull;
  Product getByPos(int idx) => items[idx];
  SavedItem getSavedByPos(int idx) => _savedItems[idx];

  List<Product> get items => _savedItems.map((item) => _products.getById(item.productId)).toList();

  double get total => _savedItems.fold(
    0.0,
    (value, element) => 
      value + ((getById(element.productId).precio == null)? 0 : getById(element.productId).precio!) * element.count
  );
  double get totalIVA => total * 1.12;

  set products(ProductsModel products) {
    _products = products;
  }

  bool addSaved(int id, {int count = 1}) {
    var modified = _products.reduceStock(id, count);

    if (modified) {
      if (contains(id)) {
        getSavedById(id)!.count = getSavedById(id)!.count + count;
      } else {
        _savedItems.add(SavedItem(productId: id, count: count));
      }
      notifyListeners();
    }

    return modified;
  }

  bool replaceSavedCount(int id, int newCount) {
    if (!contains(id)) {
      return false;
    } 

    var currentCount = getSavedById(id)!.count;
    _products.addToStock(id, currentCount);
    var modified = _products.reduceStock(id,newCount);

    if (modified) {
      getSavedById(id)!.count = newCount;
      notifyListeners();
      return true;
    }

    _products.reduceStock(id, currentCount);
    return false;
  }


  void removeSaved(int id) {
    if (!contains(id)) {
      return;
    }
    var count = getSavedById(id)!.count;
    _savedItems.removeWhere((element) => element.productId == id);
    _products.addToStock(id,count);
    notifyListeners();
  }


  void removeAllSaved() {
    _savedItems.removeRange(0, _savedItems.length);
    notifyListeners();
  }

}

class SavedItem {
  SavedItem({required this.productId, required this.count});

  final int productId;
  int count;
}
