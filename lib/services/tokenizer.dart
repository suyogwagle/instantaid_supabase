import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Hugging Face Tokenizer (WordPiece) for Flutter
class HFTokenizer {
  late Map<String, int> _vocab;
  final int maxLen;

  HFTokenizer(this._vocab, {this.maxLen = 128});

  /// Load tokenizer.json from assets
  static Future<HFTokenizer> fromAssets(String path, {int maxLen = 128}) async {
    final jsonStr = await rootBundle.loadString(path);
    final config = json.decode(jsonStr);

    // vocab is stored under "model" -> "vocab"
    final vocabMap = Map<String, int>.from(config["model"]["vocab"]);

    return HFTokenizer(vocabMap, maxLen: maxLen);
  }

  /// Encode text into input_ids and attention_mask
  Map<String, List<int>> encode(String text) {
    final tokens = _tokenize(text);

    final int clsId = _vocab["[CLS]"] ?? 101;
    final int sepId = _vocab["[SEP]"] ?? 102;
    final int unkId = _vocab["[UNK]"] ?? 100;

    List<int> inputIds = [clsId];
    for (final t in tokens) {
      inputIds.add(_vocab[t] ?? unkId);
    }
    inputIds.add(sepId);

    // Pad/truncate
    if (inputIds.length < maxLen) {
      inputIds += List.filled(maxLen - inputIds.length, 0);
    } else if (inputIds.length > maxLen) {
      inputIds = inputIds.sublist(0, maxLen);
    }

    final attentionMask = inputIds.map((e) => e == 0 ? 0 : 1).toList();

    return {
      "input_ids": inputIds,
      "attention_mask": attentionMask,
    };
  }

  /// Greedy WordPiece tokenizer
  List<String> _tokenize(String text) {
    final words = text.toLowerCase().split(RegExp(r"\s+"));
    final List<String> tokens = [];

    for (final word in words) {
      if (_vocab.containsKey(word)) {
        tokens.add(word);
      } else {
        int start = 0;
        while (start < word.length) {
          int end = word.length;
          String curSubstr = "";
          while (start < end) {
            final substr = (start > 0 ? "##" : "") + word.substring(start, end);
            if (_vocab.containsKey(substr)) {
              curSubstr = substr;
              break;
            }
            end -= 1;
          }
          if (curSubstr.isEmpty) {
            tokens.add("[UNK]");
            break;
          }
          tokens.add(curSubstr);
          start = end;
        }
      }
    }
    return tokens;
  }
}
