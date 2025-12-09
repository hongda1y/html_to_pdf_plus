import 'pdf_configuration_enums.dart';

/// Represents PDF page margins in points.
class PdfMargins {
  final double top;
  final double left;
  final double bottom;
  final double right;

  const PdfMargins({
    this.top = 40.0,
    this.left = 20.0,
    this.bottom = 40.0,
    this.right = 20.0,
  });

  /// Convenience constructor for uniform vertical margins
  const PdfMargins.symmetric({double vertical = 40.0, double horizontal = 20.0})
      : top = vertical,
        bottom = vertical,
        left = horizontal,
        right = horizontal;
}

class PdfConfiguration {
  final String targetDirectory;
  final String targetName;
  final PrintSize printSize;
  final PrintOrientation printOrientation;
  /// Make links clickable on iOS. But images must be base64 encoded
  final bool linksClickable;
  /// PDF page margins
  final PdfMargins margins;

  /// `targetDirectory` is the desired path for the PDF file.
  ///
  /// `targetName` is the name of the PDF file.
  ///
  /// `printSize` is the print size of the PDF file.
  ///
  /// `printOrientation` is the print orientation of the PDF file.
  PdfConfiguration({
    required this.targetDirectory,
    required this.targetName,
    this.printSize = PrintSize.A4,
    this.printOrientation = PrintOrientation.Portrait,
    this.linksClickable = false,
    this.margins = const PdfMargins(), // default A4-like margins
  });

  /// Returns the final path for temporary HTML file
  String get htmlFilePath => "$targetDirectory/$targetName.html";
}
