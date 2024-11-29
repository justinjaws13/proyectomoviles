import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importamos shared_preferences
import 'pokemon_details_screen.dart';
import 'queries/graphql_queries.dart'; // Importamos la consulta GraphQL

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
  'ghost': FontAwesomeIcons.ghost,
  'normal': Icons.circle,
  'poison': Icons.science,
  'ice': Icons.ac_unit,
  'dark': FontAwesomeIcons.moon,
  'steel': FontAwesomeIcons.screwdriver,
  'dragon': FontAwesomeIcons.dragon,
  'fairy': FontAwesomeIcons.wandMagic,
  'flying': FontAwesomeIcons.feather,
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
  Set<int> favoritePokemonIds = {}; // IDs de Pokémon favoritos
  bool showFavoritesOnly = false; // Mostrar solo favoritos
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
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
    _loadFavorites(); // cargo los favoritos al iniciar
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoritePokemonIds') ?? [];
    setState(() {
      favoritePokemonIds = favoriteIds.map((id) => int.parse(id)).toSet();
    });
  }

  void _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = favoritePokemonIds.map((id) => id.toString()).toList();
    prefs.setStringList('favoritePokemonIds', favoriteIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Text(
            "Pokédex",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showFavoritesOnly = !showFavoritesOnly;
              });
            },
          ),
        ],
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
                        final typeKey = type.toLowerCase();
                        return DropdownMenuItem<String>(
                          value: type.toLowerCase(),
                          child: Row(
                            children: [
                              Icon(
                                _typeIcons[typeKey] ?? Icons.help,
                                color: Colors.blueGrey[900],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(type, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value == 'all' ? null : value;
                        });
                      },
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
                    [];

                final displayedPokedex = showFavoritesOnly
                    ? pokedex.where((pokemon) => favoritePokemonIds.contains(pokemon['id'])).toList()
                    : pokedex;

                final filteredPokedex = displayedPokedex.where((pokemon) {
                  final types = (pokemon['pokemon_v2_pokemontypes'] as List?)
                      ?.map((typeData) =>
                      (typeData['pokemon_v2_type']['name'] as String).toLowerCase())
                      .toList() ??
                      [];
                  final generation = pokemon['pokemon_v2_pokemonspecy']?['generation_id'];
                  final name = (pokemon['name'] as String).toLowerCase();

                  final matchesType = selectedType == null || types.contains(selectedType);
                  final matchesGeneration =
                      selectedGeneration == null || generation == selectedGeneration;
                  final matchesSearch = searchQuery.isEmpty ||
                      name.contains(searchQuery) ||
                      pokemon['id'].toString() == searchQuery;

                  return matchesType && matchesGeneration && matchesSearch;
                }).toList();

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: filteredPokedex.length,
                  itemBuilder: (context, index) {
                    final pokemon = filteredPokedex[index];
                    final pokemonId = pokemon['id'];
                    final isFavorite = favoritePokemonIds.contains(pokemonId);

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
                              fullPokedex: pokedex,
                              filteredPokedex: filteredPokedex,
                              currentIndex: index,
                              favoritePokemonIds: favoritePokemonIds,
                              onFavoriteToggle: (pokemonId) { // callback
                                setState(() {
                                  if (favoritePokemonIds.contains(pokemonId)) {
                                    favoritePokemonIds.remove(pokemonId);
                                  } else {
                                    favoritePokemonIds.add(pokemonId);
                                  }
                                });
                                _saveFavorites(); // guardar los favoritos actualizados
                              },
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
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, left: 10),
                                  child: Text(
                                    pokemon['name'].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 5),
                                  child: Row(
                                    children: types.map((type) {
                                      return Icon(
                                        _typeIcons[type.toLowerCase()] ?? Icons.help,
                                        color: Colors.white,
                                        size: 18,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: imageUrl != null
                                        ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      height: 170,
                                      fit: BoxFit.contain,
                                    )
                                        : const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white,
                                      size: 100,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isFavorite) {
                                      favoritePokemonIds.remove(pokemonId);
                                    } else {
                                      favoritePokemonIds.add(pokemonId);
                                    }
                                  });
                                  _saveFavorites();
                                },
                                child: Icon(
                                  isFavorite ? Icons.star : Icons.star_border,
                                  color: isFavorite ? Colors.yellow : Colors.white,
                                  size: 24,
                                ),
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
