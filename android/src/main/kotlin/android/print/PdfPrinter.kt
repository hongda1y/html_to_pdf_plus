package android.print

import android.os.Build
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import java.io.File

class PdfPrinter(private val printAttributes: PrintAttributes) {

    interface Callback {
        fun onSuccess(filePath: String)
        fun onFailure()
    }

    fun print(
        printAdapter: android.print.PrintDocumentAdapter,
        path: File,
        fileName: String,
        callback: Callback
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            printAdapter.onLayout(
                null,
                printAttributes,
                null,
                object : android.print.PrintDocumentAdapter.LayoutResultCallback() {
                    override fun onLayoutFinished(info: android.print.PrintDocumentInfo, changed: Boolean) {
                        printAdapter.onWrite(
                            arrayOf(android.print.PageRange.ALL_PAGES),
                            getOutputFile(path, fileName),
                            CancellationSignal(),
                            object : android.print.PrintDocumentAdapter.WriteResultCallback() {
                                override fun onWriteFinished(pages: Array<android.print.PageRange>) {
                                    super.onWriteFinished(pages)
                                    val outputFile = File(path, fileName)
                                    if (!outputFile.exists() || pages.isEmpty()) {
                                        callback.onFailure()
                                        return
                                    }
                                    callback.onSuccess(outputFile.absolutePath)
                                }
                            })
                    }
                },
                null
            )
        } else {
            callback.onFailure()
        }
    }

    private fun getOutputFile(path: File, fileName: String): ParcelFileDescriptor {
        if (!path.exists()) {
            path.mkdirs()
        }
        val file = File(path, fileName)
        if (!file.exists()) {
            file.createNewFile()
        }
        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_WRITE)
    }
}
