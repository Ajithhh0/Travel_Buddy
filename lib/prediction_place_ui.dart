import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy/address_model.dart';
import 'package:travel_buddy/app_info.dart';
import 'package:travel_buddy/predictions.dart';

class PredictionPlaceUI extends StatefulWidget {
  final PredictionModel? predictedPlaceData;
  final TextEditingController textFieldController;
  final bool isStart;

  PredictionPlaceUI(
      {Key? key,
      this.predictedPlaceData,
      required this.textFieldController,
      required this.isStart})
      : super(key: key);

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  AddressModel model = AddressModel();
  @override
  Widget build(BuildContext context) {
    print(widget.predictedPlaceData);
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () {
  widget.textFieldController.text =
    "${widget.predictedPlaceData!.main_text}, ${widget.predictedPlaceData!.secondary_text}";

  // Create a new AddressModel
  AddressModel selectedPlaceModel = AddressModel(
    humanReadableAddress: "${widget.predictedPlaceData!.main_text}, ${widget.predictedPlaceData!.secondary_text}",
     latitudePosition: widget.predictedPlaceData!.latitude,
     longitudePosition: widget.predictedPlaceData!.longitude,
  );

  if (!widget.isStart) {
    
    Provider.of<AppInfo>(context, listen: false)
        .updateDestinationLocation(selectedPlaceModel);
  } else {
    
    Provider.of<AppInfo>(context, listen: false)
        .updateStartLocation(selectedPlaceModel);
  }
},

        child: SizedBox(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.share_location,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 13,
                  ),
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
                        const SizedBox(
                          height: 3,
                        ),
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
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
