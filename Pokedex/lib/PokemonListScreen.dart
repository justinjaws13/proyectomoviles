import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// Consulta GraphQL para obtener una lista de Pokémon con su nombre, tipo e imagen con paginación.
const String getPokemonsQuery = r'''
  query GetPokemons($limit: Int, $offset: Int) {
    pokemon_v2_pokemon(limit: $limit, offset: $offset) {
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

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final int _limit = 20;
  final int _offset = 0;
  final List _pokemons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokédex"),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonsQuery),
          variables: {'limit': _limit, 'offset': _offset},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading && _pokemons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception.toString()}'));
          }

          // Agrega los nuevos Pokémon a la lista existente
          final List newPokemons = result.data?['pokemon_v2_pokemon'] ?? [];
          _pokemons.addAll(newPokemons);

          // Configuración para obtener más resultados al hacer scroll
          FetchMoreOptions fetchMoreOptions = FetchMoreOptions(
            variables: {'offset': _pokemons.length},
            updateQuery: (previousResultData, fetchMoreResultData) {
              final List<dynamic> previousPokemons = previousResultData?['pokemon_v2_pokemon'] ?? [];
              final List<dynamic> morePokemons = fetchMoreResultData?['pokemon_v2_pokemon'] ?? [];

              return {
                'pokemon_v2_pokemon': [...previousPokemons, ...morePokemons],
              };
            },
          );

          return ListView.builder(
            itemCount: _pokemons.length + 1, // +1 para el indicador de carga al final
            itemBuilder: (context, index) {
              if (index == _pokemons.length) {
                // Al llegar al final, carga más datos
                fetchMore!(fetchMoreOptions);
                return const Center(child: CircularProgressIndicator());
              }

              final pokemon = _pokemons[index];
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
