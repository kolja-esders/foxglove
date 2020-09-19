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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildFootprint(),
            _buildIngredients(),
            _buildSuggestions(),
            // _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text, Color color) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: color),
      child: Text(text),
    );
  }

  Widget _buildIngredientPill(Ingredient ingredient, Color color) {
    return _buildPill(ingredient.name, color);
  }

  Widget _buildAlternatives(String orig, List<Ingredient> alternatives) {
    return Row(
      children: [
        _buildPill(orig, Colors.red.shade200),
        ...alternatives.map((i) => _buildIngredientPill(i, Colors.green.shade200)),
      ],
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Text(
            'How to improve',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          // ...args.alternatives.((key, value) => _buildAlternatives(key, value))
        ],
      ),
    );
  }

  Widget _buildFootprint() {
    final totalFootprint = args.ingredients.map((i) => i.footprint).reduce((a, b) => a + b) / args.ingredients.length;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          new Container(
          //width: 50.0,
          //height: 50.0,
          padding: const EdgeInsets.all(30.0),
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueGrey.shade50,
          ),
            child: new Column(
                    children: [
                      Text(
                        '$totalFootprint',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade100, fontSize: 36),
                      ),
                      Text(
                        'kg CO2',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.blue.shade100),
                      ),

                    ],
            )
          ),
        ],
      )
    );
  }


  Widget _buildIngredients() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ...args.ingredients.map((i) => _buildIngredientPill(i, Colors.red.shade200))
        ],
      ),
    );

  }

  Widget _buildImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: FancyShimmerImage(
          imageUrl: args.imageUrl,
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
