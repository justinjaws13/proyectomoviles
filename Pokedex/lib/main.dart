import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'PokemonListScreen.dart';

void main() async {
  await initHiveForFlutter(); // Necesario para el almacenamiento de GraphQL
  final HttpLink httpLink = HttpLink('https://beta.pokeapi.co/graphql/v1beta');

  final GraphQLClient client = GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: HiveStore()),
  );

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final GraphQLClient client;

  MyApp({required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier(client),
      child: MaterialApp(
        title: 'Pokédex',
        home: PokemonListScreen(),
      ),
    );
  }
}
