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
