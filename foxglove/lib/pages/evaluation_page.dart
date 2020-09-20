import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class EvaluationPage extends StatelessWidget {
  EvaluationPage(this.args) : nameToIngredient = Map.fromIterable(args.ingredients, key: (i) => i.name);
  ScrollController _controller = new ScrollController();
  EvaluationPage(this.args)
      : nameToIngredient =
            Map.fromIterable(args.ingredients, key: (i) => i.name);

  final EvaluationPageArgs args;

  final Map<String, Ingredient> nameToIngredient;

  final emojis = {
    'Potatoes':
        'https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/263/potato_1f954.png',
    'salmon':
        'https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/263/fish_1f41f.png',
    'rice':
        'https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/263/cooked-rice_1f35a.png',
    'oil':
        'https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/263/sake_1f376.png',
    'salt':
        'https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/263/salt_1f9c2.png',
    'pepper': ''
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildIngredients(),
                    _buildSuggestions(),
                    _buildInstructions(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text, {bool isGood, double footprint}) {
    final bgColor = isGood ? Colors.green.shade100 : Colors.red.shade100;
    final fgColor = isGood ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), color: bgColor),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Text(text.replaceAll('_', ' ')),
            if (footprint != null)
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2), color: fgColor),
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                margin: EdgeInsets.only(left: 4),
                child: Text(
                  '${footprint.toStringAsFixed(2)} kg CO\u2082',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ));
  }

  Widget _buildPill2(String text, double footprint, String emoji) {
    final updatedText =
        '${text.toUpperCase().substring(0, 1)}${text.substring(1)}'
            .replaceAll('_', ' ');

    return Container(
      //decoration:
      //   BoxDecoration(borderRadius: BorderRadius.circular(4), color: color),
      padding: EdgeInsets.all(8),
      child: Column(children: [
        Image.network(
            emojis[text] ??
                'https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/263/bento-box_1f371.png',
            scale: 2.0),
        Text(
          updatedText,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        Text(footprint.toStringAsFixed(2) + "kg CO2",
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _buildIngredientPill2(Ingredient ingredient) {
    return _buildPill2(ingredient.name, ingredient.footprint, "coffee");
  }

  Widget _buildIngredientPill(Ingredient ingredient, Color color) {
    return _buildPill(ingredient.name,
        isGood: true, footprint: ingredient.footprint);
  }

  Widget _buildAlternatives(String orig, List<Ingredient> alternatives) {
    List<Widget> widgets = alternatives
        .map((i) => _buildIngredientPill(i, Colors.green.shade100))
        .toList();
    widgets = widgets.expand((element) => [element, Text(', ')]).toList();
    widgets = widgets.take(widgets.length - 1).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text('Replace '),
            _buildPill(orig,
                isGood: false, footprint: nameToIngredient[orig].footprint),
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 32),
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
    final totalFootprint =
        args.ingredients.map((i) => i.footprint).reduce((a, b) => a + b) /
            args.ingredients.length;

    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 36.0, right: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Container(
                padding: const EdgeInsets.all(12.0),
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.shade200.withOpacity(0.9),
                    border: Border.all(
                        width: 3,
                        color: Colors.orange.shade500.withOpacity(0.9))),
                child: new Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${totalFootprint.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          letterSpacing: -1.5,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                    Text(
                      'kg CO\u2082',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
          ],
        ));
  }

  Widget _buildIngredients() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [...args.ingredients.map((i) => _buildIngredientPill2(i))],
        ),
      ),
    );
  }

  Widget _buildSingleInstruction(int idx, String instruction) {
    print(instruction);
    return ListTile(
      leading: Icon(Icons.arrow_forward),
      /* Text(
        idx.toString() + '.',
        style: TextStyle(fontWeight: FontWeight.bold),
      ), */
      title: Text(instruction),
    );
  }

  Widget _buildInstructions() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeadline('Instructions'),
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _controller,
              shrinkWrap: true,
              children: <Widget>[
                ...args.instructions
                    .asMap()
                    .entries
                    .map((x) => _buildSingleInstruction(x.key + 1, x.value))
              ],
            ),
          ],
        ));
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: FancyShimmerImage(
              imageUrl: args.imageUrl,
            ),
          ),
          Container(
            height: 350.0,
            decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: [
                      0.5,
                      1.0
                    ])),
          ),
          Positioned(
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                args.title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Positioned(
            child: _buildFootprint(),
            top: 0,
            right: 0,
          )
        ],
      ),
    );
  }
}

class EvaluationPageArgs {
  EvaluationPageArgs(
      {this.imageUrl,
      this.title,
      this.instructions,
      this.ingredients,
      this.alternatives,
      this.newIngredients});

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
