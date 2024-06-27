import 'package:proyecto_final_movil/model/order.dart';
import 'package:proyecto_final_movil/model/products.dart';
import 'package:proyecto_final_movil/model/shopping_cart.dart';
import 'package:proyecto_final_movil/model/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShoppingCart extends StatelessWidget {
  ShoppingCart({super.key});

  Future<void> handlePurchase(BuildContext context) async {
    var shoppingCart = Provider.of<ShoppingCartModel>(context, listen: false);
    var user = Provider.of<UserModel>(context, listen: false);
    var orders = Provider.of<ProductOrderModel>(context, listen: false);

    if (user.userId == null) {
      context.push("/login");
      return;
    }

    var details = shoppingCart.items.map((e) => OrderDetail(
          idProducto: e.idProducto,
          cantidad: shoppingCart.getSavedById(e.idProducto!)!.count,
          precio: e.precio,
          total: e.precio! * shoppingCart.getSavedById(e.idProducto!)!.count,
        ));

    await user.getUserWithClient(user.userCid!).then((usr) {
      if (usr == null) {
        return Future.value(false);
      }

      var order = ProductOrder(
        cliente: {
          "cedulaCliente": usr.cedulaCliente,
          "nombreCompleto": usr.nombreCompleto,
          "correo": usr.correo,
          "direccion": usr.direccion,
        },
        total: shoppingCart.totalIVA,
        detalleVenta: details.toList(),
      );
      return orders.postOrder(order);
    }).then((correct) {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text(correct
                  ? 'Orden Agregada Correctamente'
                  : 'Error al agregar la orden'),
              content: Text(
                  correct ? 'Se ha agregado una orden 😀' : 'Pipipii.. 😞'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (correct) {
                      Provider.of<ShoppingCartModel>(context, listen: false)
                          .removeAllSaved();
                      Provider.of<ProductsModel>(context, listen: false)
                          .fetchProducts(context);
                      Provider.of<ProductOrderModel>(context, listen: false)
                          .fetchOrders(context);
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                      return;
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    var total = context
        .select<ShoppingCartModel, double>((products) => products.totalIVA);
    var productCount =
        context.select<ShoppingCartModel, int>((products) => products.count);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Carrito de Compras'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: _List(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: productCount == 0
              ? null
              : () async {
                  await handlePurchase(context);
                },
          child: Text(
              "Comprar ${NumberFormat.currency(symbol: '\$').format(total)}  (Incluye IVA)"),
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var itemNameStyle = Theme.of(context)
        .textTheme
        .titleLarge!
        .copyWith(overflow: TextOverflow.ellipsis);
    var itemCountStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.secondary);
    var cart = context.watch<ShoppingCartModel>();

    return SliverList.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) => ListTile(
        leading: IconButton(
            onPressed: () {
              context.push("/item/${cart.items[index].idProducto!}");
            },
            icon: const Icon(Icons.remove_red_eye)),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            cart.removeSaved(cart.items[index].idProducto!);
            if (cart.items.isEmpty) {
              context.pop(true);
            }
          },
        ),
        title: Text(
          cart.items[index].nombre!,
          style: itemNameStyle,
        ),
        subtitle: Text(
          "${cart.getSavedByPos(index).count} ${cart.getSavedByPos(index).count == 1 ? "Unidad" : "Unidades"}",
          style: itemCountStyle,
        ),
      ),
    );
  }
}
