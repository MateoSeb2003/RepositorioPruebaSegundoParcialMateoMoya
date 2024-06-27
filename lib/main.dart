import 'package:proyecto_final_movil/model/order.dart';
import 'package:proyecto_final_movil/model/user.dart';
import 'package:proyecto_final_movil/model/shopping_cart.dart';
import 'package:proyecto_final_movil/model/products.dart';
import 'package:proyecto_final_movil/screens/edit.dart';
import 'package:proyecto_final_movil/screens/login.dart';
import 'package:proyecto_final_movil/screens/more.dart';
import 'package:proyecto_final_movil/screens/order_details.dart';
import 'package:proyecto_final_movil/screens/order_history.dart';
import 'package:proyecto_final_movil/screens/register.dart';
import 'package:proyecto_final_movil/screens/user_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_movil/screens/home.dart';
import 'package:proyecto_final_movil/screens/shopping_cart.dart';
import 'package:proyecto_final_movil/screens/product.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsModel()),
        ChangeNotifierProxyProvider<ProductsModel, ShoppingCartModel>(
          create: (context) => ShoppingCartModel(),
          update: (context, products, cart) {
            if (cart == null) throw ArgumentError.notNull('cart');
            cart.products = products;
            return cart;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProxyProvider<UserModel, ProductOrderModel>(
            create: (context) => ProductOrderModel(),
            update: (context, users, orders) {
              if (orders == null) throw ArgumentError.notNull('orders');
              orders.user = users;
              return orders;
            }),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Cliente Móvil',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 66, 124, 169)),
          useMaterial3: false,
        ),
        routerConfig: router(),
      ),
    );
  }
}

GoRouter router() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MyHomePage(),
        routes: const [],
      ),
      GoRoute(
        path: '/shopcart',
        builder: (context, state) => ShoppingCart(),
        routes: const [],
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) =>
            ProductInformation(productId: state.pathParameters['id']),
        routes: const [],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => Login(),
        routes: const [],
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const Register(),
        routes: const [],
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (context, state) =>
            EditUser(idUsuario: state.pathParameters['id']!),
        routes: const [],
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const UserMenu(),
        routes: const [],
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const OrderHistory(),
        routes: const [],
      ),
      GoRoute(
        path: '/order_details/:id',
        builder: (context, state) =>
            OrderDetails(orderId: state.pathParameters['id']),
        routes: const [],
      ),
      GoRoute(
        path: '/cathegory/:name',
        builder: (context, state) =>
            MoreItems(cathegory: state.pathParameters['name']!),
        routes: const [],
      )
    ],
  );
}
