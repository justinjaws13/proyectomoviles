const String getTotalPokemonCountQuery = """
  query getTotalPokemonCount {
    pokemon_v2_pokemon_aggregate {
      aggregate {
        count
      }
    }
  }
""";