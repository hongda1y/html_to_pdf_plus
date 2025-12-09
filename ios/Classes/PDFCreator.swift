import UIKit

class PDFCreator {

    /**
     Creates a PDF using the given print formatter and saves it to the user's document directory.
     - Parameters:
        - printFormatter: UIPrintFormatter from WebView/HTML
        - width: PDF width in points (A4 default)
        - height: PDF height in points (A4 default)
        - margins: Margins for top, left, bottom, right (default 40 pt top/bottom, 20 pt left/right)
     - Returns: URL of generated PDF
     */
    class func create(
        printFormatter: UIPrintFormatter,
        width: Double = 595.2,   // A4 width @ 72 dpi
        height: Double = 841.8,  // A4 height @ 72 dpi
        margins: UIEdgeInsets = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
    ) -> URL {

        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        // A4 page rectangle
        let paperRect = CGRect(x: 0, y: 0, width: width, height: height)

        // Printable area adjusted for margins
        let printableRect = CGRect(
            x: margins.left,
            y: margins.top,
            width: width - margins.left - margins.right,
            height: height - margins.top - margins.bottom
        )

        // Set renderer paper & printable rects
        renderer.setValue(paperRect, forKey: "paperRect")
        renderer.setValue(printableRect, forKey: "printableRect")

        // PDF context
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)

        // Render pages
        for pageIndex in 0 ..< renderer.numberOfPages {
            UIGraphicsBeginPDFPageWithInfo(paperRect, nil)
            renderer.drawPage(at: pageIndex, in: printableRect)
        }

        UIGraphicsEndPDFContext()

        // Save PDF
        let url = createdFileURL
        do {
            try pdfData.write(to: url, options: .atomic)
        } catch {
            fatalError("Error writing PDF: \(error.localizedDescription)")
        }

        return url
    }

    // MARK: - Helper: Temporary PDF URL
    private class var createdFileURL: URL {
        let directory = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return directory
            .appendingPathComponent("generatedPdfFile")
            .appendingPathExtension("pdf")
    }
}
