import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A 1x1 transparent PNG.
final Uint8List kTransparentPng = Uint8List.fromList(const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

/// Returns a transparent image for every asset key.
///
/// Before answering an [AssetImage], Flutter loads the asset manifest through
/// this same bundle. The manifest must stay decodable, otherwise the image
/// resolution fails with "Message corrupted", so those keys get a real (empty)
/// manifest instead of the PNG.
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    switch (key) {
      case 'AssetManifest.bin':
        return const StandardMessageCodec().encodeMessage(<String, Object>{})!;
      case 'AssetManifest.json':
        return _utf8('{}');
      case 'FontManifest.json':
        return _utf8('[]');
      default:
        return ByteData.view(kTransparentPng.buffer);
    }
  }

  ByteData _utf8(String value) =>
      ByteData.view(Uint8List.fromList(utf8.encode(value)).buffer);
}

/// Wraps [child] so any [AssetImage] below it resolves to a dummy image.
Widget withTestAssets(Widget child) =>
    DefaultAssetBundle(bundle: TestAssetBundle(), child: child);