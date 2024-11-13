import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'pokemon_details_screen.dart';

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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? selectedType;
  int? selectedGeneration;
  late AnimationController _animationController;

  final List<String> types = [
    'All', 'Grass', 'Fire', 'Water', 'Electric', 'Rock', 'Ground', 'Psychic',
    'Fighting', 'Bug', 'Ghost', 'Normal', 'Poison', 'Ice', 'Dragon', 'Dark',
    'Fairy', 'Steel', 'Flying'
  ];
  final List<int?> generations = [null, 1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
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
            hint: const Text("Filtro por Generación"),
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
            top: 35,
            right: 105,
            child: Image.asset('images/pokedexlogo1.png', width: 200, fit: BoxFit.fitWidth),
          ),
          Positioned(
            top: 140,
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

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: filteredPokedex.length,
                  itemBuilder: (context, index) {
                    final pokemon = filteredPokedex[index];

                    // Obtener todos los tipos de Pokémon
                    final types = (pokemon['pokemon_v2_pokemontypes'] as List)
                        .map((typeData) => typeData['pokemon_v2_type']['name'] as String)
                        .toList();

                    final spriteData = pokemon['pokemon_v2_pokemonsprites'][0]['sprites'];
                    final imageUrl = spriteData != null ? spriteData['front_default'] : null;

                    return FadeTransition(
                      opacity: _animationController,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PokemonDetailScreen(
                                pokemonDetail: pokemon,
                                color: _getTypeColor(types[0]),
                                heroTag: index,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getTypeColor(types[0]),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, left: 10),
                                  child: Text(
                                    pokemon['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25, // Tamaño de fuente más grande para el nombre
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: types.map((type) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 4.0),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                          color: Colors.black26,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                                          child: Text(
                                            type,
                                            style: const TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Hero(
                                      tag: 'pokemon_image_$index',
                                      child: imageUrl != null
                                          ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        height: 180, // Imagen más grande
                                        fit: BoxFit.fitHeight,
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.error, color: Colors.red),
                                      )
                                          : const Icon(Icons.image_not_supported, color: Colors.white, size: 80),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
      case 'dark':
        return Colors.black87;
      case 'steel':
        return Colors.blueGrey;
      default:
        return Colors.pink;
    }
  }
}
