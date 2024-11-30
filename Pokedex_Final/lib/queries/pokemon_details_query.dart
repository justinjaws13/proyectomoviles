const String getPokemonDetailsQuery = """
  query GetPokemonDetails(\$id: Int!) {
    pokemon_v2_pokemon_by_pk(id: \$id) {
      id
      name
      height
      weight
      pokemon_v2_pokemonspecy {
        evolves_from_species_id
      }
      pokemon_v2_pokemonabilities {
        pokemon_v2_ability {
          name
        }
      }
    }
  }
""";
