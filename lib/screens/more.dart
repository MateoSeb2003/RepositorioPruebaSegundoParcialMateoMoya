import 'package:proyecto_final_movil/components/shopping_cart_sum.dart';
//import 'package:cliente_movil/model/order.dart';
import 'package:proyecto_final_movil/model/products.dart';
import 'package:proyecto_final_movil/model/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MoreItems extends StatefulWidget {
  const MoreItems({super.key, required this.cathegory});

  final String cathegory;

  @override
  State<StatefulWidget> createState() => _MoreItems();
}

class _MoreItems extends State<MoreItems> {
  late List<Product> _list;
  late String? _cathegory;

  Future<void> refresh() async {
    Provider.of<ProductsModel>(context, listen: false).fetchProducts(context);
    _cathegory = widget.cathegory;
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ProductsModel>(context, listen: false).fetchProducts(context);
    _cathegory = widget.cathegory;
  }

  @override
  Widget build(BuildContext context) {
    _list = context.select<ProductsModel, List<Product>>(
        (p) => p.getByCathegoryName(_cathegory!));
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                _cathegory!,
              ),
              actions: [
                const ShoppingCartSummary(),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  tooltip: 'Usuario',
                  onPressed: () {
                    var token =
                        Provider.of<UserModel>(context, listen: false).token;

                    if (token == null) {
                      context.push('/login');
                      return;
                    }
                    context.push('/menu');
                  },
                ),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList.builder(
              itemCount: _list.length,
              itemBuilder: (context, index) =>
                  _GalleryCard(product: _list[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 10,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          context.push("/item/${product.idProducto}");
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  child: Hero(
                    tag: 'product_img_${product.idProducto}',
                    child: CachedNetworkImage(
                      imageUrl: product.urlImagen!,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 3.0,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child:
                        Text(product.nombre!, overflow: TextOverflow.ellipsis),
                  ),
                ],
              )),
              FittedBox(
                child: Column(
                  children: [
                    Column(
                      children: [
                        const Text("En stock"),
                        Text("${product.stock ?? 0}")
                      ],
                    ),
                    Text(
                      NumberFormat.currency(locale: "en_US", decimalDigits: 2)
                          .format(product.precio),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
