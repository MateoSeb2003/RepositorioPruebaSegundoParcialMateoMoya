import 'package:proyecto_final_movil/model/order.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderHistory extends StatelessWidget {
  const OrderHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Historial de Compras'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: _List(),
          ),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  static final _f = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    var itemNameStyle = Theme.of(context).textTheme.titleLarge!.copyWith(overflow: TextOverflow.ellipsis);
    var itemCountStyle = Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.secondary);
    var model = context.watch<ProductOrderModel>();

    return SliverList.builder(
      itemCount: model.count,
      itemBuilder: (context, index) => ListTile(
        trailing: IconButton(
          onPressed: () {
            context.push("/order_details/${model.getByPos(index).idVenta!}");
          },
          icon: const Icon(Icons.remove_red_eye)
        ),
        title: Text(
          "Venta No. ${model.getByPos(index).numeroDocumento}",
          style: itemNameStyle,
        ),
        subtitle: Text(
          "${_f.format(model.getByPos(index).fechaRegistro ?? DateTime.now())} | ${NumberFormat.currency().format(model.getByPos(index).total ?? 0)}",
          style: itemCountStyle,
        ),
      ),
    );
  }
}
