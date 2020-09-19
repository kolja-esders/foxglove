import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class EvaluationPage extends StatelessWidget {
  EvaluationPage(this.args);

  final EvaluationPageArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carbon Foodprint'),
      ),
      body: Column(
        children: [
          _buildImage(),
          _buildFootprint(),
          // _buildSuggestions(),
          // _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildFootprint() {
    final totalFootprint = args.ingredients.map((i) => i.footprint).reduce((a, b) => a + b);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 16.0),
      child: Text('CO2 footprint: $totalFootprint'),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FancyShimmerImage(
            imageUrl: args.imageUrl,
          ),
        ),
      ),
    );
  }
}

class EvaluationPageArgs {
  EvaluationPageArgs(
      {this.imageUrl, this.title, this.instructions, this.ingredients, this.alternatives, this.newIngredients});

  final String title;

  final Map<String, List<Ingredient>> alternatives;

  final String imageUrl;

  final List<String> instructions;

  final List<Ingredient> ingredients;

  final List<Ingredient> newIngredients;
}

class Ingredient {
  Ingredient(this.name, this.footprint);

  final String name;

  final double footprint;

  @override
  String toString() {
    return '$name: $footprint';
  }
}
