import UIKit

class PDFCreator {

    
    /**
     Creates a PDF using the given print formatter and saves it to the user's document directory.
     - Parameters:
        - printFormatter: UIPrintFormatter from WebView/HTML
        - width: PDF width in points (A4 default)
        - height: PDF height in points (A4 default)
        - margins: Margins for top, left, bottom, right (can be zero)
     - Returns: URL of generated PDF
     */
    class func create(
        printFormatter: UIPrintFormatter,
        width: Double = 595.2,
        height: Double = 841.8,
        margins: UIEdgeInsets = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
    ) -> URL {

        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        let paperRect = CGRect(x: 0, y: 0, width: width, height: height)

        // Ensure printable width/height are at least 1 point to avoid blank PDF
        let printableWidth = max(1, width - margins.left - margins.right)
        let printableHeight = max(1, height - margins.top - margins.bottom)

        let printableRect = CGRect(
            x: margins.left,
            y: margins.top,
            width: printableWidth,
            height: printableHeight
        )

        // Use KVC to set the paper & printable rects
        renderer.setValue(paperRect, forKey: "paperRect")
        renderer.setValue(printableRect, forKey: "printableRect")

        // Begin PDF context
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)

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
