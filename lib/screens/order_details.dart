import 'package:proyecto_final_movil/model/order.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetails extends StatelessWidget {
  const OrderDetails({super.key,required this.orderId});
  static final _f = DateFormat('EEEE d \'de\' MMMM \'del\' y', 'es_ES');

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    var order = context.select<ProductOrderModel,ProductOrder>((order) => order.getById(int.parse(orderId!)));
    var subtotal = order.detalleVenta?.map((order) { return order.total!; }).reduce((p,n) { return p + n; });
    var iva = (subtotal ?? 0) * 0.12;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Detalles de Venta.'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverList.list(
              children: [
                Text(
                  'Detalles Generales.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: Theme.of(context).textTheme.bodyMedium?.fontSize,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Flexible(
                              child: Text(_f.format(order.fechaRegistro ?? DateTime.now())),
                            ),
                          ),
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: Theme.of(context).textTheme.bodyMedium?.fontSize,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("Número de documento: ${order.numeroDocumento}"),
                          ),
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            order.tipoPago == "Tarjeta" ? Icons.credit_card : Icons.account_balance_wallet,
                            size: Theme.of(context).textTheme.bodyMedium?.fontSize,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("Pagado con ${order.tipoPago}"),
                          ),
                        ]
                      ),
                      Divider(color: Theme.of(context).colorScheme.tertiary),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: Theme.of(context).textTheme.bodyMedium?.fontSize,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("Subtotal: ${NumberFormat.currency().format(subtotal)}"),
                          ),
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: Theme.of(context).textTheme.bodyMedium?.fontSize,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("IVA: ${NumberFormat.currency().format(iva)}"),
                          ),
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: Theme.of(context).textTheme.bodyMedium?.fontSize,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("Total: ${NumberFormat.currency().format(order.total)}"),
                          ),
                        ]
                      ),
                    ],
                  ),
                )
              ]
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: _List(orderId: orderId),
          ),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.orderId});
  
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    var order = context.select<ProductOrderModel,ProductOrder>((order) => order.getById(int.parse(orderId!)));
    var itemNameStyle = Theme.of(context).textTheme.titleLarge!.copyWith(overflow: TextOverflow.ellipsis);
    var itemCountStyle = Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.secondary);
     
    return SliverList.builder(
      itemCount: order.detalleVenta?.length,
      itemBuilder: (context, index) => ListTile(
        trailing: IconButton(
          onPressed: () {
            context.push("/item/${order.detalleVenta?[index].idProducto!}");
          },
          icon: const Icon(Icons.remove_red_eye)
        ),
        title: Text(
          order.detalleVenta![index].productoDescription!,
          style: itemNameStyle,
        ),
        subtitle: Text(
          "${order.detalleVenta![index].cantidad} ${order.detalleVenta![index].cantidad == 1? "Unidad" : "Unidades" }",
          style: itemCountStyle,
        ),
      ),
    );
  }
}
