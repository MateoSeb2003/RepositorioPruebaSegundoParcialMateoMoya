import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:proyecto_final_movil/model/products.dart';
import 'package:proyecto_final_movil/model/shopping_cart.dart';
import 'package:proyecto_final_movil/components/shopping_cart_sum.dart';

class ProductInformation extends StatefulWidget {
  const ProductInformation({super.key, required this.productId});

  final String? productId;

  @override
  State<StatefulWidget> createState() => _ProductInformationState();
}

class _ProductInformationState extends State<ProductInformation> {
  int currCount = 1;

  void addToCart(int id, int count, ShoppingCartModel cart, BuildContext context) {
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingrese al menos un elemento'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    var modified = cart.contains(id) ? cart.replaceSavedCount(id, count) : cart.addSaved(id, count: count);
    if (!modified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock Insuficiente. Selecciona una cantidad menor o igual al stock disponible.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto agregado al carrito'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    int id = int.tryParse(widget.productId!)!;
    var cart = Provider.of<ShoppingCartModel>(context, listen: false);
    var countInCar = cart.getSavedById(id)?.count;

    if (countInCar == null) {
      return;
    }

    setState(() {
      currCount = countInCar;
    });
  }

  @override
  Widget build(BuildContext context) {
    int id = int.tryParse(widget.productId!)!;
    var cart = context.watch<ShoppingCartModel>();
    var product = context.select<ProductsModel, Product>((sc) => sc.getById(id));
    var isInCart = cart.contains(id);
    var countInCar = cart.getSavedById(id)?.count;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              "Vista de producto",
            ),
            backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(0xe0),
            foregroundColor: Theme.of(context).colorScheme.primary,
            actions: const [
              ShoppingCartSummary(),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(5),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Hero(
                    tag: 'product_img_$id',
                    child: Image(
                        image: CachedNetworkImageProvider(product.urlImagen!),
                        width: double.infinity,
                        fit: BoxFit.cover)),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(left: 25, right: 5, top: 5),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Text(
                            "\$",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                          ),
                          Text(
                            NumberFormat.currency()
                                .format(product.precio!)
                                .replaceFirst("USD", ""),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                                width: 2.0),
                            borderRadius:
                                BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            FittedBox(
                              child: IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    final newValue =
                                        currCount - 1;
                                    currCount =
                                        newValue.clamp(
                                            1, product.stock!);
                                    if (isInCart) {
                                      cart.replaceSavedCount(
                                          id, currCount);
                                    }
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: NumberPicker(
                                selectedTextStyle:
                                    Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                value: currCount,
                                minValue: 1,
                                maxValue: product.stock!,
                                step: 1,
                                itemCount: 1,
                                itemWidth: 75,
                                haptics: true,
                                zeroPad: false,
                                axis: Axis.vertical,
                                onChanged: (value) {
                                  setState(() {
                                    currCount = value;
                                  });
                                },
                              ),
                            ),
                            FittedBox(
                              child: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    final newValue =
                                        currCount + 1;
                                    currCount =
                                        newValue.clamp(
                                            1, product.stock!);
                                    if (isInCart) {
                                      cart.replaceSavedCount(
                                          id, currCount);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                    product.nombre!,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 20),
                    child: Text(
                        "Características",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge)),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.fontSize,
                          color: Theme.of(context)
                              .colorScheme
                              .outline,
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.only(
                                    left: 5),
                            child: Text(
                                "Categoría: ${product.categoriaDescription}")),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.warehouse,
                          size: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.fontSize,
                          color: Theme.of(context)
                              .colorScheme
                              .outline,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(
                                  left: 5),
                          child: Text(
                              "En stock: ${product.stock ?? 0}"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          isInCart
                              ? Icons.shopping_cart
                              : Icons
                                  .shopping_cart_outlined,
                          size: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.fontSize,
                          color: Theme.of(context)
                              .colorScheme
                              .outline,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(
                                  left: 5),
                          child: Text(isInCart
                              ? "En el carrito: $countInCar"
                              : "No agregado al carrito"),
                        ),
                      ],
                    ),
                  ],
                )
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: countInCar == null
          ? FloatingActionButton.extended(
              onPressed: () {
                addToCart(product.idProducto!, currCount, cart, context);
              },
              icon: isInCart
                  ? const Icon(Icons.shopping_cart)
                  : const Icon(Icons.shopping_cart_outlined),
              label: Text(
                "Agregar al carrito",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondary,
                        ),
              ),
            )
          : null,
    );
  }
}
