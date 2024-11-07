import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// Consulta GraphQL para obtener una lista de Pokémon con su nombre, tipo e imagen.
const String getPokemonsQuery = r'''
  query {
    pokemon_v2_pokemon(limit: 20) {
      id
      name
      pokemon_v2_pokemonsprites {
        sprites
      }
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
''';

class PokemonListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pokédex"),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonsQuery),
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception.toString()}'));
          }

          final List pokemons = result.data?['pokemon_v2_pokemon'] ?? [];

          return ListView.builder(
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final pokemon = pokemons[index];
              final name = pokemon['name'];
              final types = pokemon['pokemon_v2_pokemontypes']
                  .map((type) => type['pokemon_v2_type']['name'])
                  .join(', ');

              final sprites = pokemon['pokemon_v2_pokemonsprites'][0]?['sprites'];
              final imageUrl = sprites != null ? jsonDecode(sprites)['front_default'] : '';

              return ListTile(
                leading: imageUrl.isNotEmpty
                    ? Image.network(imageUrl)
                    : Container(width: 40, height: 40, color: Colors.grey),
                title: Text(name),
                subtitle: Text('Type: $types'),
              );
            },
          );
        },
      ),
    );
  }
}
