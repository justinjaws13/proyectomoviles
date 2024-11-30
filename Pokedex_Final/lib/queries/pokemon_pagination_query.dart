const String getPokemonPaginationQuery = """
query GetPokemonPagination(\$offset: Int!, \$limit: Int!) {
  pokemon_v2_pokemon(limit: \$limit, offset: \$offset) {
    id
    name
    pokemon_v2_pokemontypes {
      pokemon_v2_type {
        name
      }
    }
    pokemon_v2_pokemonspecy {
      generation_id
    }
    pokemon_v2_pokemonsprites {
      sprites
    }
  }
}
""";
