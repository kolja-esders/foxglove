import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class EvaluationPage extends StatelessWidget {
  EvaluationPage(this.imageUrl);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carbon Foodprint'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: FancyShimmerImage(
                  imageUrl: imageUrl,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

@JsonSerializable(nullable: false)
class EvaluationPageArgs {
  EvaluationPageArgs({this.imageUrl, this.instructions, this.ingredients, this.alternatives});

  final Map<String, String> alternatives;

  final String imageUrl;

  final List<String> instructions;

  final Map<String, double> ingredients;
}
