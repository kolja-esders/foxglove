import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class EvaluationPage extends StatelessWidget {
  EvaluationPage(this.args) : nameToIngredient = Map.fromIterable(args.ingredients, key: (i) => i.name);

  final EvaluationPageArgs args;

  final Map<String, Ingredient> nameToIngredient;

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
            _buildSuggestions(),
            // _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text, {bool isGood, double footprint}) {
    final bgColor = isGood ? Colors.green.shade100 : Colors.red.shade100;
    final fgColor = isGood ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: bgColor),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Text(text),
            if (footprint != null)
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: fgColor),
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                margin: EdgeInsets.only(left: 4),
                child: Text(
                  '$footprint kg CO\u2082',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ));
  }

  Widget _buildIngredientPill(Ingredient ingredient, Color color) {
    return _buildPill(ingredient.name, isGood: true, footprint: ingredient.footprint);
  }

  Widget _buildAlternatives(String orig, List<Ingredient> alternatives) {
    List<Widget> widgets = alternatives.map((i) => _buildIngredientPill(i, Colors.green.shade100)).toList();
    widgets = widgets.expand((element) => [element, Text(', ')]).toList();
    widgets = widgets.take(widgets.length - 1).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text('Replace '),
            _buildPill(orig, isGood: false, footprint: nameToIngredient[orig].footprint),
            Text(' with '),
            ...widgets,
            Text('.'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
      ),
    );
  }

  Widget _buildSuggestions() {
    final alternatives = <Widget>[];
    for (final alternative in args.alternatives.keys) {
      final ingredients = args.alternatives[alternative];
      alternatives.add(_buildAlternatives(alternative, ingredients));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeadline('How to improve'),
          ...alternatives,
        ],
      ),
    );
  }

  Widget _buildFootprint() {
    final totalFootprint = args.ingredients.map((i) => i.footprint).reduce((a, b) => a + b) / args.ingredients.length;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 16.0),
      child: Text('CO2 footprint: $totalFootprint'),
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
