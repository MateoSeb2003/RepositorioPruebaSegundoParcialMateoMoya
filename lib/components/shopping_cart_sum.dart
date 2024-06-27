import 'package:flutter/material.dart';
import 'package:proyecto_final_movil/model/shopping_cart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ShoppingCartSummary extends StatelessWidget {
  const ShoppingCartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingCartModel>(
        builder: (context,cart,child) {
          var value = cart.count >= 10 ? "9+" : NumberFormat("#").format(cart.count);

          if (cart.count == 0) {
            return Center(
              child:  Stack(
                children: [
                  IconButton(
                    onPressed: () { context.push('/shopcart');},
                    icon: const Icon(Icons.shopping_basket),
                  ),
                ],
              )
            );
          }

        return Center(
            child: Stack(
              children: [
                IconButton(
                  onPressed: () { context.push('/shopcart');},
                  icon: const Icon(Icons.shopping_basket),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold
                      )
                    ),
                  )
                )
              ],
            )
          );
        }
    );
  }
}
