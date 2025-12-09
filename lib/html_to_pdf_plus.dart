import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:html_to_pdf_plus/file_utils.dart';

import 'pdf_configuration.dart';
import 'pdf_configuration_enums.dart';

export 'pdf_configuration.dart';
export 'pdf_configuration_enums.dart';

/// HTML to PDF Converter
class HtmlToPdf {
  static const MethodChannel _channel =
      MethodChannel('flutter_html_to_pdf');

  /// Creates PDF Document from HTML content
  static Future<File> convertFromHtmlContent({
    required String htmlContent,
    required PdfConfiguration configuration,
  }) async {
    final File temporaryCreatedHtmlFile =
        await FileUtils.createFileWithStringContent(
      htmlContent,
      configuration.htmlFilePath,
    );
    await FileUtils.appendStyleTagToHtmlFile(temporaryCreatedHtmlFile.path);

    final String generatedPdfFilePath = await _convertFromHtmlFilePath(
      temporaryCreatedHtmlFile.path,
      configuration,
    );

    temporaryCreatedHtmlFile.delete();

    return FileUtils.copyAndDeleteOriginalFile(
      generatedPdfFilePath,
      configuration.targetDirectory,
      configuration.targetName,
    );
  }

  /// Creates PDF Document from File that contains HTML content
  static Future<File> convertFromHtmlFile({
    required File htmlFile,
    required PdfConfiguration configuration,
  }) async {
    await FileUtils.appendStyleTagToHtmlFile(htmlFile.path);
    final String generatedPdfFilePath = await _convertFromHtmlFilePath(
      htmlFile.path,
      configuration,
    );

    return FileUtils.copyAndDeleteOriginalFile(
      generatedPdfFilePath,
      configuration.targetDirectory,
      configuration.targetName,
    );
  }

  /// Creates PDF Document from path to File that contains HTML content
  static Future<File> convertFromHtmlFilePath({
    required String htmlFilePath,
    required PdfConfiguration configuration,
  }) async {
    await FileUtils.appendStyleTagToHtmlFile(htmlFilePath);
    final generatedPdfFilePath = await _convertFromHtmlFilePath(
      htmlFilePath,
      configuration,
    );

    return FileUtils.copyAndDeleteOriginalFile(
        generatedPdfFilePath,
        configuration.targetDirectory,
        configuration.targetName);
  }

  /// Assumes the invokeMethod call will return successfully
  static Future<String> _convertFromHtmlFilePath(
    String htmlFilePath,
    PdfConfiguration configuration,
  ) async {
    int width = configuration.printSize
        .getDimensionsInPixels[configuration.printOrientation.getWidthDimensionIndex];
    int height = configuration.printSize
        .getDimensionsInPixels[configuration.printOrientation.getHeightDimensionIndex];

    // Pass margins to native iOS plugin
    return await _channel.invokeMethod(
      'convertHtmlToPdf',
      <String, dynamic>{
        'htmlFilePath': htmlFilePath,
        'width': width,
        'height': height,
        'printSize': configuration.printSize.printSizeKey,
        'orientation': configuration.printOrientation.orientationKey,
        'linksClickable': configuration.linksClickable,
        'marginTop': configuration.margins.top,
        'marginLeft': configuration.margins.left,
        'marginBottom': configuration.margins.bottom,
        'marginRight': configuration.margins.right,
      },
    ) as String;
  }
}
