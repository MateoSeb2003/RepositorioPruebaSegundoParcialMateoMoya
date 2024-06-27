import 'package:carousel_slider/carousel_slider.dart';
import 'package:proyecto_final_movil/components/shopping_cart_sum.dart';
import 'package:proyecto_final_movil/model/order.dart';
import 'package:proyecto_final_movil/model/products.dart';
import 'package:proyecto_final_movil/model/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _MyHomPage();
}

class _MyHomPage extends State<MyHomePage> {
  Future<void> refresh() async {
    Provider.of<ProductsModel>(context, listen: false).fetchProducts(context);
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ProductsModel>(context, listen: false).fetchProducts(context);
    Provider.of<ProductOrderModel>(context, listen: false).fetchOrders(context);
    Provider.of<UserModel>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          slivers: [
            const _AppBar(),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList.builder(
              itemCount: context.select<ProductsModel,int>((p) => p.cathegories().length),
              itemBuilder: (context, index) => _CathegorySection(idx: index),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
 const _AppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      title: const Text('Artículos'),
      actions: <Widget> [
        const ShoppingCartSummary(),
        IconButton(
          icon: const Icon(Icons.account_circle),
          tooltip: 'Usuario',
          onPressed: () {
            var token = Provider.of<UserModel>(context, listen: false).token;

            if (token == null) {
              context.push('/login');
              return;
            }
            context.push('/menu');
          },
        ),
      ],
      scrolledUnderElevation: 4.0,
    );
  }
}


class _CathegorySection extends StatelessWidget {
  const _CathegorySection({required this.idx});
  
  final int idx;
  
  List<String> cathegories(BuildContext context) => context.select<ProductsModel, List<String>>((products) => products.cathegories());
  
  Iterable<Container> elements(BuildContext context) {
    var cathegoryList = cathegories(context);
    
    if (cathegoryList.isEmpty || idx < 0 || idx >= cathegoryList.length) {
      return []; // Return an empty list if cathegory list is empty or index is out of bounds
    }
    
    var cathegory = cathegoryList[idx];
    var products = context.select<ProductsModel, List<Product>>((products) => products.getByCathegoryName(cathegory));
    
    if (products.isEmpty) {
      return []; // Return an empty list if no products found for this cathegory
    }
    
    return products
        .take(5) // Limit to 5 products per cathegory
        .map((product) => Container(
              margin: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: InkWell(
                  onTap: () {
                    context.push("/item/${product.idProducto}");
                  },
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'product_img_${product.idProducto}',
                        child: CachedNetworkImage(
                          imageUrl: product.urlImagen!,
                          height: 250,
                          width: 500,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 3.0,),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 0, 0, 0),
                                Color.fromARGB(1, 0, 0, 0),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Column(
                              children: [
                                Text(
                                  product.nombre ?? "foo",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(
                                      locale: "en_US", decimalDigits: 2)
                                      .format(product.precio ?? 0),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        ?.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ]
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ))
        .toList();
  }
  
  @override
  Widget build(BuildContext context) {
    if (context.select<ProductsModel, bool>((p) => p.loading)) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
        ),
      );
    }
    var cathegoryList = cathegories(context);
    
    if (cathegoryList.isEmpty || idx < 0 || idx >= cathegoryList.length) {
      return SizedBox(); // Return an empty SizedBox if cathegory list is empty or index is out of bounds
    }
    
    var cathegory = cathegoryList[idx];
    
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 10,
        child: Padding(
          padding:
          const EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cathegory,
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: false,
                  aspectRatio: 2.0,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.6,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                ),
                items: elements(context)
                    .followedBy([
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    child: Center(
                      child: FittedBox(
                        child: Column(
                          children: [
                            IconButton(
                              iconSize: 40,
                              onPressed: () {
                                context.push("/cathegory/$cathegory");
                              },
                              icon: const Icon(Icons.arrow_forward),
                            ),
                            const Text("Mostrar más")
                          ],
                        ),
                      ),
                    ),
                  )
                ])
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
