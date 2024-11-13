import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'pokemon_details_screen.dart';
import 'dart:convert';

const String getPokemonListQuery = """
  query {
    pokemon_v2_pokemon{
      name
      height
      weight
      pokemon_v2_pokemonspecy {
        generation_id
        evolution_chain_id
        evolves_from_species_id
        pokemon_v2_evolutionchain {
          pokemon_v2_pokemonspecies {
            name
          }
        }
      }
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedType;
  int? selectedGeneration;

  final List<String> types = [
    'All', 'Grass', 'Fire', 'Water', 'Electric', 'Rock', 'Ground', 'Psychic',
    'Fighting', 'Bug', 'Ghost', 'Normal', 'Poison', 'Ice', 'Dragon', 'Dark',
    'Fairy', 'Steel', 'Flying'
  ];
  final List<int?> generations = [null, 1, 2, 3, 4, 5, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokedex"),
        actions: [
          DropdownButton<String>(
            value: selectedType,
            hint: const Text("Filtro por Tipo"),
            items: types.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedType = value == 'All' ? null : value;
              });
            },
          ),
          DropdownButton<int?>(
            value: selectedGeneration,
            hint: const Text("Filtro por Generation"),
            items: generations.map((gen) {
              return DropdownMenuItem<int?>(
                value: gen,
                child: Text(gen == null ? "Todas" : "Gen $gen"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGeneration = value;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Image.asset('images/pokeball2-remove.png', width: 200, fit: BoxFit.fitWidth),
          ),
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
                  return Center(child: Text('Error al cargar datos: ${result.exception.toString()}'));
                }

                final pokedex = result.data?['pokemon_v2_pokemon'] ?? [];

                // Filtro de Pokémon según tipo y generación
                final filteredPokedex = pokedex.where((pokemon) {
                  final types = (pokemon['pokemon_v2_pokemontypes'] as List)
                      .map((typeData) => (typeData['pokemon_v2_type']['name'] as String).toLowerCase())
                      .toList();
                  final generation = pokemon['pokemon_v2_pokemonspecy']?['generation_id'];

                  final typeMatches = selectedType == null || types.contains(selectedType!.toLowerCase());
                  final generationMatches = selectedGeneration == null || generation == selectedGeneration;

                  return typeMatches && generationMatches;
                }).toList();


                return SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: filteredPokedex.length,
                    itemBuilder: (context, index) {
                      final pokemon = filteredPokedex[index];
                      final type = pokemon['pokemon_v2_pokemontypes'].isNotEmpty
                          ? pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name']
                          : 'Unknown';

                      final spriteData = pokemon['pokemon_v2_pokemonsprites'][0]['sprites'];
                      final imageUrl = spriteData['front_default']; // Acceso directo sin json.decode

                      return InkWell(
                          child: AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 500),
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
                      child: Hero(
                      tag: 'pokemon_image_$index',
                      child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 100,
                      fit: BoxFit.fitHeight,
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                      ),
                      ),
                      ),
                      ],
                      ),
                      ),
                      ),
                          ),
                      onTap: () {Navigator.push(
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
      case 'grass':
        return Colors.greenAccent;
      case 'fire':
        return Colors.redAccent;
      case 'water':
        return Colors.blue;
      case 'electric':
        return Colors.yellowAccent;
      case 'rock':
        return Colors.grey;
      case 'ground':
        return Colors.brown;
      case 'psychic':
        return Colors.indigo;
      case 'fighting':
        return Colors.orangeAccent;
      case 'bug':
        return Colors.lightGreenAccent;
      case 'ghost':
        return Colors.deepPurple;
      case 'normal':
        return Colors.black26;
      case 'poison':
        return Colors.deepPurpleAccent;
      case 'ice':
        return Colors.lightBlueAccent;
      default:
        return Colors.pink;
    }
  }
}
