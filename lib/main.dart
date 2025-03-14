import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // Needed to decode API response

void main() {
  runApp(PokemonApp());
}

// Main App Widget
class PokemonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PokemonListScreen(), // Show the Pokémon list screen
    );
  }
}

// Stateful Widget to Handle API Fetch and Search
class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<dynamic> pokemonCards = []; // Stores fetched Pokémon cards
  List<dynamic> filteredPokemonCards = []; // Stores filtered Pokémon cards for search
  TextEditingController searchController = TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    fetchPokemonCards(); // Fetch Pokémon data when screen loads
  }

  // Fetch Pokémon card data from API
  Future<void> fetchPokemonCards() async {
    final response = await http.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        pokemonCards = data['data']; // Store the full list of Pokémon cards
        filteredPokemonCards = pokemonCards; // Initialize filtered list
      });
    } else {
      throw Exception('Failed to load Pokémon cards');
    }
  }

  // Function to filter Pokémon cards based on search input
  void filterPokemonCards(String query) {
    setState(() {
      filteredPokemonCards = pokemonCards
          .where((card) =>
          card['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pokémon Cards')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Pokémon...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: filterPokemonCards, // Update list when typing
            ),
          ),
          // List of Pokémon Cards (Scrollable)
          Expanded(
            child: filteredPokemonCards.isEmpty
                ? Center(child: CircularProgressIndicator()) // Show loading spinner
                : ListView.builder(
              itemCount: filteredPokemonCards.length,
              itemBuilder: (context, index) {
                final card = filteredPokemonCards[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(card['images']['small']), // Small image
                    title: Text(card['name']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(card),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Screen to Show Pokémon Card Image
class DetailScreen extends StatelessWidget {
  final dynamic card;
  DetailScreen(this.card);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(card['name'])),
      body: Center(
        child: Image.network(card['images']['large']), // Show large Pokémon image
      ),
    );
  }
}
