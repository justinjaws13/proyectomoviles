const String getPokemonListQuery = """
query GetPokemonList {
  pokemon_v2_pokemon(limit: 100) {
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
