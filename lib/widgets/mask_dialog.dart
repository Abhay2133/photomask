import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photomask/util.dart';

typedef Uint8ListCallback = void Function(Uint8List data);

class MaskDialog extends StatefulWidget {
  final Uint8List image;
  final List<List<dynamic>> masks;
  final Uint8ListCallback onSelect;

  const MaskDialog({super.key, required this.image, required this.onSelect, required this.masks});
  @override
  State<MaskDialog> createState() => _MaskDialogState();
}

class _MaskDialogState extends State<MaskDialog> {
  late Uint8List previewImage;
  @override
  void initState() {
    super.initState();
    previewImage = Uint8List.fromList(widget.image);
  }

  void _maskImage(int index) async {
    if (index == -1) {
      setState(() {
        previewImage = Uint8List.fromList(widget.image);
      });
      return;
    }
    final maskedOutput = await applyMask(widget.image, widget.masks[index][2]);
    if (maskedOutput != null) {
      setState(() {
        previewImage = maskedOutput;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 200.0, // Set your minimum height here
            minWidth: 300.0, // Optional: set a minimum width
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // header
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text('Uploaded Image',
                            style: TextStyle(
                                fontSize: 18,
                                color: Color.fromRGBO(0, 0, 0, 0.8))),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded))
                  ],
                ),
                const SizedBox(height: 16),

                // image
                Image.memory(previewImage, fit: BoxFit.cover),
                const SizedBox(height: 16),

                // Masks
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            _maskImage(-1);
                          },
                          child: const Text("Original")),
                      ...widget.masks.map((item) {
                        final index = item[0];
                        final path = item[1];
                        return Row(
                          children: [
                            const SizedBox(width: 10.0),
                            GestureDetector(
                              onTap: () {
                                _maskImage(index);
                              },
                              child: Image.asset(
                                path, // Replace with your image asset path
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ],
                        );
                      })
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSelect(previewImage);
                    // setState(() {
                    //   outputImageBytes = selectedImage;
                    // });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Use This Image'),
                ),
              ],
            ),
          ),
        ));
  }

  }
