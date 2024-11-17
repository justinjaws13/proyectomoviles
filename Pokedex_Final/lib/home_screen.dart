import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'pokemon_details_screen.dart';

const String getPokemonListQuery = """
  query {
    pokemon_v2_pokemon(order_by: {id: asc}) {
      id
      name
      height
      weight
      pokemon_v2_pokemonspecy {
        generation_id
        evolves_from_species_id
        pokemon_v2_evolutionchain {
          pokemon_v2_pokemonspecies(order_by: {id: asc}) {
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

// Iconos para los tipos de Pokémon
const Map<String, IconData> _typeIcons = {
  'grass': Icons.grass,
  'fire': Icons.local_fire_department,
  'water': Icons.water_drop,
  'electric': Icons.flash_on,
  'rock': Icons.terrain_outlined,
  'ground': Icons.landscape,
  'psychic': Icons.psychology,
  'fighting': Icons.sports_mma,
  'bug': Icons.bug_report,
  'ghost': FontAwesomeIcons.ghost, // Usando FontAwesome para Ghost
  'normal': Icons.circle,
  'poison': Icons.science,
  'ice': Icons.ac_unit,
  'dark': FontAwesomeIcons.moon, // Usando un ícono de luna para Dark
  'steel': FontAwesomeIcons.screwdriver, // Usando FontAwesome para Steel
  'dragon': FontAwesomeIcons.dragon, // Usando FontAwesome para Dragon
  'fairy': FontAwesomeIcons.wandMagic, // Usando FontAwesome para Fairy
  'flying': FontAwesomeIcons.feather, // Usando FontAwesome para Flying
};


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? selectedType;
  int? selectedGeneration;
  String searchQuery = "";
  late AnimationController _animationController;
  final TextEditingController searchController = TextEditingController();

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
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Pokédex", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar Pokémon por nombre o número",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: selectedType,
                      hint: const Text("Tipo"),
                      items: types.map((type) {
                        final typeKey = type.toLowerCase(); // Convertir a minúscula para el mapa
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _typeIcons[typeKey] ?? Icons.help, // Icono del tipo o un ícono de ayuda predeterminado
                                color: Colors.blueGrey[900],
                                size: 20,
                              ),
                              const SizedBox(width: 8), // Espaciado entre el icono y el texto
                              Text(
                                type,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value == 'All' ? null : value;
                        });
                      },
                      dropdownColor: Colors.white, // Color del menú desplegable
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),

                    DropdownButton<int?>(
                      value: selectedGeneration,
                      hint: const Text("Generación"),
                      items: generations.map((gen) {
                        return DropdownMenuItem<int?>(
                          value: gen,
                          child: Text(gen == null ? 'Gen' : "Gen $gen"),
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
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
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

                final pokedex = (result.data?['pokemon_v2_pokemon'] as List?)
                    ?.cast<Map<String, dynamic>>() ??
                    []; // Evita errores en caso de datos null

                // Filtro de Pokémon según tipo y generación
                final filteredPokedexByTypeAndGen = pokedex.where((pokemon) {
                  final types = (pokemon['pokemon_v2_pokemontypes'] as List?)
                      ?.map((typeData) =>
                      (typeData['pokemon_v2_type']['name'] as String).toLowerCase())
                      .toList() ??
                      [];
                  final generation = pokemon['pokemon_v2_pokemonspecy']?['generation_id'];

                  final typeMatches = selectedType == null || types.contains(selectedType!.toLowerCase());
                  final generationMatches = selectedGeneration == null || generation == selectedGeneration;


                  return typeMatches && generationMatches;
                }).toList();

                // Aplicar búsqueda
                final filteredPokedex = filteredPokedexByTypeAndGen.where((pokemon) {
                  final index = filteredPokedexByTypeAndGen.indexOf(pokemon) + 1;
                  return searchQuery.isEmpty ||
                      pokemon['name'].toLowerCase().contains(searchQuery) ||
                      index.toString() == searchQuery;
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

                    // Manejo seguro de datos
                    final types = (pokemon['pokemon_v2_pokemontypes'] as List?)
                        ?.map((typeData) => typeData['pokemon_v2_type']['name'] as String)
                        .toList() ??
                        ['Unknown'];

                    final spriteData = pokemon['pokemon_v2_pokemonsprites']?.first['sprites'];
                    final imageUrl = spriteData != null ? spriteData['front_default'] : null;


                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PokemonDetailScreen(
                              pokemonList: pokedex,
                              currentIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getTypeColor(types.first).withOpacity(0.8),
                              _getTypeColor(types.first).withOpacity(0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(2, 4),
                              blurRadius: 6,
                            ),
                          ],
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
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 5),
                              child: Row(
                                children: types.map((type) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Icon(
                                      _typeIcons[type.toLowerCase()] ?? Icons.help,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: imageUrl != null
                                    ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  height: 120,
                                  fit: BoxFit.fitHeight,
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, color: Colors.red),
                                )
                                    : const Icon(Icons.image_not_supported,
                                    color: Colors.white, size: 80),
                              ),
                            ),
                          ],
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
        return Colors.pinkAccent;
    }
  }
}
