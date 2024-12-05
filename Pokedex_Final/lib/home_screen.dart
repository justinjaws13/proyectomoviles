import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pokedex_final/FilterSection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pokemon_details_screen.dart';
import 'queries/graphql_queries.dart';

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
  String? selectedAbility;
  String? selectedSortOrder;
  String searchQuery = "";
  Set<String> favoritePokemonIds = {};
  bool showFavoritesOnly = false;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  int? minPower = 0;
  int? maxPower = 800;
  RangeValues powerRange = const RangeValues(0, 800);

  final Map<String, Color> typeColors = {
    'grass': Colors.greenAccent,
    'fire': Colors.redAccent,
    'water': Colors.blue,
    'electric': Colors.yellowAccent,
    'rock': Colors.grey,
    'ground': Colors.brown,
    'psychic': Colors.purpleAccent,
    'fighting': Colors.orangeAccent,
    'bug': Colors.lightGreenAccent,
    'ghost': Colors.deepPurple,
    'normal': Colors.black26,
    'poison': Colors.deepPurpleAccent,
    'ice': Colors.lightBlueAccent,
    'dark': Colors.black87,
    'steel': Colors.blueGrey,
    'fairy': Colors.pinkAccent,
    'dragon': Colors.indigoAccent,
    'flying': Colors.cyan,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _loadFavorites();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favoritePokemonIds') ?? [];
      setState(() {
        favoritePokemonIds = favoriteIds.toSet();
      });
    } catch (e) {
      print("Error al cargar favoritos: $e");
    }
  }

  void _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favoritePokemonIds', favoritePokemonIds.toList());
  }

  void _toggleFavorite(String pokemonId) {
    setState(() {
      if (favoritePokemonIds.contains(pokemonId)) {
        favoritePokemonIds.remove(pokemonId);
      } else {
        favoritePokemonIds.add(pokemonId);
      }
    });
    _saveFavorites();
  }

  /// Función para obtener el color según el tipo del Pokémon
  Color _getTypeColor(String type) {
    return typeColors[type.toLowerCase()] ?? Colors.grey;
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
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.2),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                showFavoritesOnly ? Icons.star : Icons.star_border,
                color: Colors.yellow,
                size: 28,
              ),
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
            child: FiltersSection(
              types: const [
                'All', 'Grass', 'Fire', 'Water', 'Electric', 'Rock', 'Ground', 'Psychic',
                'Fighting', 'Bug', 'Ghost', 'Normal', 'Poison', 'Ice', 'Dragon', 'Dark',
                'Fairy', 'Steel', 'Flying'
              ],
              typeIcons: _typeIcons,
              generations: const [null, 1, 2, 3, 4, 5, 6, 7, 8],
              abilities: const [
                'All', 'Overgrow', 'Blaze', 'Torrent', 'Static', 'Poison Point', 'Swift Swim',
                'Intimidate', 'Levitate', 'Chlorophyll', 'Guts', 'Keen Eye', 'Sturdy',
                'Inner Focus', 'Compound Eyes', 'Sand Stream', 'Pressure', 'Synchronize',
                'Thick Fat', 'Immunity', 'Flash Fire', 'Flame Body', 'Water Absorb',
                'Volt Absorb', 'Cute Charm', 'Shell Armor', 'Natural Cure', 'Run Away',
                'Pickup', 'Early Bird', 'Truant', 'Hustle', 'Marvel Scale', 'Battle Armor',
                'Hyper Cutter', 'Soundproof', 'Effect Spore', 'Arena Trap', 'Vital Spirit',
                'Rain Dish', 'Speed Boost', 'Magic Guard', 'Filter', 'Iron Barbs',
                'Adaptability', 'Sheer Force', 'Mold Breaker', 'Prankster', 'Rough Skin',
                'Lightning Rod', 'Unburden', 'Technician', 'Mega Launcher', 'Contrary',
                'Bulletproof', 'Strong Jaw', 'Protean', 'Drought', 'Defiant', 'Victory Star',
                'Snow Warning', 'Solar Power', 'Steadfast', 'No Guard', 'Reckless',
                'Multiscale', 'Magic Bounce', 'Pixilate', 'Parental Bond', 'Dark Aura',
                'Fairy Aura', 'Aura Break', 'Shadow Shield',
              ],
              sortOptions: const ['Number', 'Name', 'Power', 'Type', 'Abilities'],
              selectedType: selectedType,
              onTypeChanged: (value) {
                setState(() {
                  selectedType = value == 'All' ? null : value?.toLowerCase();
                });
              },
              selectedGeneration: selectedGeneration,
              onGenerationChanged: (value) {
                setState(() {
                  selectedGeneration = value;
                });
              },
              selectedAbility: selectedAbility,
              onAbilityChanged: (value) {
                setState(() {
                  selectedAbility = value;
                });
              },
              powerRange: powerRange,
              onPowerRangeChanged: (range) {
                setState(() {
                  powerRange = range;
                  minPower = range.start.toInt();
                  maxPower = range.end.toInt();
                });
              },
              selectedSortOrder: selectedSortOrder,
              onSortOrderChanged: (value) {
                setState(() {
                  selectedSortOrder = value;
                });
              },
              onSearchQueryChanged: (query) {
                setState(() {
                  searchQuery = query.trim().toLowerCase();
                });
              },
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
                  return Center(
                    child: Text(
                      'Error al cargar datos: ${result.exception.toString()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final pokedex = (result.data?['pokemon_v2_pokemon'] as List?)
                    ?.cast<Map<String, dynamic>>() ??
                    [];

                final displayedPokedex = showFavoritesOnly
                    ? pokedex.where((pokemon) => favoritePokemonIds.contains(pokemon['id'].toString())).toList()
                    : pokedex;

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: displayedPokedex.length,
                  itemBuilder: (context, index) {
                    final pokemon = displayedPokedex[index];
                    final pokemonId = pokemon['id'].toString();
                    final isFavorite = favoritePokemonIds.contains(pokemonId);
                    final types = (pokemon['pokemon_v2_pokemontypes'] as List?)
                        ?.map((typeData) => typeData['pokemon_v2_type']['name'] as String)
                        .toList() ??
                        ['Unknown'];
                    final mainType = types.isNotEmpty ? types.first.toLowerCase() : 'unknown';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PokemonDetailScreen(
                              fullPokedex: pokedex,
                              filteredPokedex: displayedPokedex,
                              currentIndex: index,
                              favoritePokemonIds: favoritePokemonIds.map(int.parse).toSet(),
                              onFavoriteToggle: (id) => _toggleFavorite(id.toString()),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getTypeColor(mainType).withOpacity(0.8),
                              _getTypeColor(mainType).withOpacity(0.4),
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
                                Expanded(
                                  child: Center(
                                    child: CachedNetworkImage(
                                      imageUrl: pokemon['pokemon_v2_pokemonsprites']
                                          ?.first['sprites']['front_default'] ??
                                          'https://via.placeholder.com/150',
                                      height: 170,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => _toggleFavorite(pokemonId),
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
}
