import 'package:flutter/material.dart';
import 'package:travel_buddy/predictions.dart';

class PredictionPlaceUI extends StatefulWidget {
  final PredictionModel? predictedPlaceData;
  final TextEditingController textFieldController;

  PredictionPlaceUI({Key? key, this.predictedPlaceData, required this.textFieldController}) : super(key: key);

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () {
          widget.textFieldController.text =
              "${widget.predictedPlaceData!.main_text}, ${widget.predictedPlaceData!.secondary_text}";
          //Navigator.pop(context);
        },
        child: SizedBox(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              Row(
                children: [
                  const Icon(
                    Icons.share_location,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 13,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.predictedPlaceData!.main_text.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3,),
                        Text(
                          widget.predictedPlaceData!.secondary_text.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}