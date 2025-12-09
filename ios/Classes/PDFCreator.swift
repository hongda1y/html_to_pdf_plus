import UIKit

class PDFCreator {

    /**
     Creates a PDF using the given print formatter and saves it to the user's document directory.
     - Parameters:
        - printFormatter: UIPrintFormatter from WebView/HTML
        - width: PDF width in points (A4 default)
        - height: PDF height in points (A4 default)
        - verticalMargin: Top and bottom margin (default 20.0 pt)
     - Returns: URL of generated PDF
     */
    class func create(printFormatter: UIPrintFormatter,
                      width: Double = 595.2,   // A4 width @ 72 dpi
                      height: Double = 841.8,  // A4 height @ 72 dpi
                      verticalMargin: Double = 40.0) -> URL {

        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        // A4 page rectangle
        let paperRect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )

        // Printable area: only top and bottom margins
        let printableRect = CGRect(
            x: 0,  // full width
            y: verticalMargin,  // top margin
            width: width,       // full width
            height: height - 2 * verticalMargin  // subtract top & bottom
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

    /**
     Creates a temporary PDF file URL.
     */
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

    /**
     Regex helper (optional)
     */
    private class func matches(for regex: String, in text: String) -> [String] {
        do {
            let reg = try NSRegularExpression(pattern: regex)
            let ns = text as NSString
            let results = reg.matches(in: text, range: NSRange(location: 0, length: ns.length))
            return results.map { ns.substring(with: $0.range) }
        } catch {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
