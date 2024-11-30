const String getPokemonByIdOrNameQuery = """
query GetPokemonByIdOrName(\$id: Int, \$name: String) {
  pokemon_v2_pokemon(where: {_or: [{id: {_eq: \$id}}, {name: {_ilike: \$name}}]}) {
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
