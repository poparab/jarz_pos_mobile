import 'dart:math' as math;

final RegExp _arabicPattern = RegExp(r'[\u0600-\u06FF]');

enum PrinterPaperSize { mm58, mm80 }

class PrinterCompatibilitySettings {
  const PrinterCompatibilitySettings({
    this.paperSize = PrinterPaperSize.mm80,
    this.printLogo = false,
    this.rasterizeArabicText = true,
    this.rasterizeStyledText = false,
    this.rasterWidthPx = 384,
    this.codeTable = 0,
    this.bleChunkSize = 96,
    this.bleChunkDelayMs = 30,
    this.classicChunkSize = 192,
    this.classicChunkDelayMs = 18,
    this.classicTailDelayMs = 1200,
  });

  final PrinterPaperSize paperSize;
  final bool printLogo;
  final bool rasterizeArabicText;
  final bool rasterizeStyledText;
  final int rasterWidthPx;
  final int codeTable;
  final int bleChunkSize;
  final int bleChunkDelayMs;
  final int classicChunkSize;
  final int classicChunkDelayMs;
  final int classicTailDelayMs;

  factory PrinterCompatibilitySettings.defaults() =>
      const PrinterCompatibilitySettings();

  factory PrinterCompatibilitySettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PrinterCompatibilitySettings.defaults();
    }

    const paperSize = PrinterPaperSize.mm80;

    return PrinterCompatibilitySettings(
      paperSize: paperSize,
      printLogo: _parseBool(json['printLogo'], fallback: false),
      rasterizeArabicText: _parseBool(
        json['rasterizeArabicText'],
        fallback: true,
      ),
      rasterizeStyledText: _parseBool(
        json['rasterizeStyledText'],
        fallback: false,
      ),
      rasterWidthPx: _parseInt(json['rasterWidthPx'], fallback: 384),
      codeTable: _parseInt(json['codeTable'], fallback: 0),
      bleChunkSize: _parseInt(json['bleChunkSize'], fallback: 96),
      bleChunkDelayMs: _parseInt(json['bleChunkDelayMs'], fallback: 30),
      classicChunkSize: _parseInt(json['classicChunkSize'], fallback: 192),
      classicChunkDelayMs: _parseInt(json['classicChunkDelayMs'], fallback: 18),
      classicTailDelayMs: _parseInt(json['classicTailDelayMs'], fallback: 1200),
    ).normalized();
  }

  Map<String, dynamic> toJson() => {
    'paperSize': paperSize.name,
    'printLogo': printLogo,
    'rasterizeArabicText': rasterizeArabicText,
    'rasterizeStyledText': rasterizeStyledText,
    'rasterWidthPx': effectiveRasterWidthPx,
    'codeTable': normalized().codeTable,
    'bleChunkSize': normalized().bleChunkSize,
    'bleChunkDelayMs': normalized().bleChunkDelayMs,
    'classicChunkSize': normalized().classicChunkSize,
    'classicChunkDelayMs': normalized().classicChunkDelayMs,
    'classicTailDelayMs': normalized().classicTailDelayMs,
  };

  PrinterCompatibilitySettings copyWith({
    PrinterPaperSize? paperSize,
    bool? printLogo,
    bool? rasterizeArabicText,
    bool? rasterizeStyledText,
    int? rasterWidthPx,
    int? codeTable,
    int? bleChunkSize,
    int? bleChunkDelayMs,
    int? classicChunkSize,
    int? classicChunkDelayMs,
    int? classicTailDelayMs,
  }) {
    return PrinterCompatibilitySettings(
      paperSize: paperSize ?? this.paperSize,
      printLogo: printLogo ?? this.printLogo,
      rasterizeArabicText: rasterizeArabicText ?? this.rasterizeArabicText,
      rasterizeStyledText: rasterizeStyledText ?? this.rasterizeStyledText,
      rasterWidthPx: rasterWidthPx ?? this.rasterWidthPx,
      codeTable: codeTable ?? this.codeTable,
      bleChunkSize: bleChunkSize ?? this.bleChunkSize,
      bleChunkDelayMs: bleChunkDelayMs ?? this.bleChunkDelayMs,
      classicChunkSize: classicChunkSize ?? this.classicChunkSize,
      classicChunkDelayMs: classicChunkDelayMs ?? this.classicChunkDelayMs,
      classicTailDelayMs: classicTailDelayMs ?? this.classicTailDelayMs,
    );
  }

  PrinterCompatibilitySettings normalized() {
    return copyWith(
      paperSize: PrinterPaperSize.mm80,
      rasterWidthPx: effectiveRasterWidthPx,
      codeTable: codeTable.clamp(0, 255).toInt(),
      bleChunkSize: bleChunkSize.clamp(48, 512).toInt(),
      bleChunkDelayMs: bleChunkDelayMs.clamp(0, 1000).toInt(),
      classicChunkSize: classicChunkSize.clamp(64, 2048).toInt(),
      classicChunkDelayMs: classicChunkDelayMs.clamp(0, 1000).toInt(),
      classicTailDelayMs: classicTailDelayMs.clamp(0, 5000).toInt(),
    );
  }

  int get paperWidthDots => 576;

  int get lineChars => 48;

  int get effectiveRasterWidthPx {
    final clamped = rasterWidthPx.clamp(384, paperWidthDots).toInt();
    return math.max(384, (clamped ~/ 8) * 8);
  }

  int get effectiveLogoWidthPx {
    final preferred = (effectiveRasterWidthPx * 0.75).round();
    const cap = 360;
    return math
        .min(
          math.max(192, preferred),
          math.max(192, effectiveRasterWidthPx - 32),
        )
        .clamp(192, cap)
        .toInt();
  }

  bool shouldRasterizeText(
    String text, {
    String? fontFamily,
    double? fontSize,
  }) {
    if (_arabicPattern.hasMatch(text)) {
      return rasterizeArabicText;
    }

    return rasterizeStyledText && (fontFamily != null || fontSize != null);
  }

  static bool _parseBool(dynamic value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized.isEmpty) {
        return fallback;
      }
      if (['1', 'true', 'yes', 'y', 'on'].contains(normalized)) {
        return true;
      }
      if (['0', 'false', 'no', 'n', 'off'].contains(normalized)) {
        return false;
      }
    }
    return fallback;
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }
}
