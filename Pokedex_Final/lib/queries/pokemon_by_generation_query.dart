const String getPokemonByGenerationQuery = """
query GetPokemonByGeneration(\$generation: Int!) {
  pokemon_v2_pokemon(where: {pokemon_v2_pokemonspecy: {generation_id: {_eq: \$generation}}}) {
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
