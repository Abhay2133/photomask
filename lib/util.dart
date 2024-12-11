import 'package:image/image.dart' as img;
import 'dart:io';

import 'package:flutter/services.dart';

Future<Uint8List> readFileAsUint8List(String filePath) async {
  // Create a File instance for the given path
  File file = File(filePath);

  // Read the file as bytes
  Uint8List fileBytes = await file.readAsBytes();

  return fileBytes;
}

Future<Uint8List> readAssetFile(String assetPath) async {
  ByteData byteData = await rootBundle.load(assetPath);
  return byteData.buffer.asUint8List();
}

Future<Uint8List?> applyMask(Uint8List src, Uint8List mask) async {

  // Decode the source image and mask image
  img.Image sourceImage = img.decodeImage(src)!;
  img.Image maskImage = img.decodeImage(mask)!;

  // Resize the mask image to match the dimensions of the source image
  maskImage = img.copyResize(maskImage,
      width: sourceImage.width,
      height: sourceImage.height,
      interpolation: img.Interpolation.average);

  // Align the mask image to the center of the source image
  int offsetX = (sourceImage.width - maskImage.width) ~/ 2;
  int offsetY = (sourceImage.height - maskImage.height) ~/ 2;

  // Create a new blank image with the same dimensions as the source image
  img.Image centeredMask =
      img.Image(width: sourceImage.width, height: sourceImage.height);

  // Fill the new image with transparent black
  img.fill(centeredMask, color: maskImage.getColor(0, 0, 0));

  // Draw the resized mask onto the centeredMask
  // copyInto(centeredMask, maskImage, dstX: offsetX, dstY: offsetY);
  for (int y = 0; y < maskImage.height; y++) {
    for (int x = 0; x < maskImage.width; x++) {
      img.Pixel pixel = maskImage.getPixel(x, y);
      centeredMask.setPixel(x + offsetX, y + offsetY, pixel);
    }
  }

  // Apply the mask to the source image
  for (int y = 0; y < sourceImage.height; y++) {
    for (int x = 0; x < sourceImage.width; x++) {
      // Get the pixel values of the centered mask and source images
      img.Pixel maskPixel = centeredMask.getPixel(x, y);
      img.Pixel srcPixel = sourceImage.getPixel(x, y);

      // If the mask is black (0), make the pixel in the source image black
      if (maskPixel.r == 0 && maskPixel.g == 0 && maskPixel.b == 0) {
        // sourceImage.setPixel(
        //     x, y, maskImage.getColor(0, 0, 0, 0)); // Apply black mask
        sourceImage.setPixelRgba(x, y, 255, 255, 255, 255);
      } else {
        // Otherwise, keep the original color
        sourceImage.setPixel(x, y, srcPixel);
      }
    }
  }

  // Encode the modified image back to Uint8List
  return Uint8List.fromList(img.encodePng(sourceImage));
}
