import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'pokemon_details_screen.dart';

const String getPokemonListQuery = """
  query {
    pokemon_v2_pokemon(limit: 50) {
      name
      height
      weight
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
      pokemon_v2_pokemonabilities {
        pokemon_v2_ability {
          name
        }
      }
      pokemon_v2_pokemonstats {
        base_stat
        pokemon_v2_stat {
          name
        }
      }
      pokemon_v2_pokemonmoves(limit: 5) {  
        pokemon_v2_move {
          name
        }
      }
      pokemon_v2_pokemonsprites {
        sprites
      }
    }
  }
""";


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background image (pokeball)
          Positioned(
            top: -50,
            right: -50,
            child: Image.asset('images/pokeball2-remove.png', width: 200, fit: BoxFit.fitWidth),
          ),
          // Title
          Positioned(
            top: 80,
            left: 20,
            child: Text(
              "Pokedex",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          // Query and GridView of Pokémon
          Positioned(
            top: 150,
            bottom: 0,
            width: width,
            child: Query(
              options: QueryOptions(
                document: gql(getPokemonListQuery),
              ),
              builder: (QueryResult result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (result.hasException) {
                  // Display the exact error to understand what’s going wrong
                  return Center(child: Text('Error al cargar datos: ${result.exception.toString()}'));
                }

                // Extract the list of Pokémon
                final pokedex = result.data?['pokemon_v2_pokemon'] ?? [];

                return SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: pokedex.length,
                    itemBuilder: (context, index) {
                      final pokemon = pokedex[index];
                      final type = pokemon['pokemon_v2_pokemontypes'].isNotEmpty
                          ? pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name']
                          : 'Unknown';

                      final spriteData = pokemon['pokemon_v2_pokemonsprites'][0]['sprites'];
                      final imageUrl = spriteData['front_default']; // Acceso directo sin json.decode


                      return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getTypeColor(type),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 30,
                                  left: 10,
                                  child: Text(
                                    pokemon['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 52,
                                  left: 10,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.black26,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                                      child: Text(
                                        type,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    height: 100,
                                    fit: BoxFit.fitHeight,
                                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PokemonDetailScreen(
                                pokemonDetail: pokemon,
                                color: _getTypeColor(type),
                                heroTag: index,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to get the color based on Pokémon type
  Color _getTypeColor(String type) {
    switch (type) {
      case 'Grass':
        return Colors.greenAccent;
      case 'Fire':
        return Colors.redAccent;
      case 'Water':
        return Colors.blue;
      case 'Electric':
        return Colors.yellowAccent;
      case 'Rock':
        return Colors.grey;
      case 'Ground':
        return Colors.brown;
      case 'Psychic':
        return Colors.indigo;
      case 'Fighting':
        return Colors.orangeAccent;
      case 'Bug':
        return Colors.lightGreenAccent;
      case 'Ghost':
        return Colors.deepPurple;
      case 'Normal':
        return Colors.black26;
      case 'Poison':
        return Colors.deepPurpleAccent;
      case 'Ice':
        return Colors.lightBlueAccent;
      default:
        return Colors.pink;
    }
  }
}
