# Archive Books

Simple pipeline to create high quality PDF books out of JPG files.

How to:

1. Download a book of your choice [archive downloader](https://github.com/AllLiveSupport/Archive-Borrowed-Book-Downloader)
2. Move all images into a directory called 'high'
3. Clone this repo
4. Run the script with parameter, being in the parent of the 'high' resolution images: `clean.sh jb2`

Run `clean.sh ocr` after `clean.sh jb2` to OCR the existing per-page PDFs in `out/pdfjb2`, one at a time, then merge the results into `out/<book>-jb2-ocr.pdf`. OCRmyPDF's temporary files are cleaned up normally. `OCR_LANG` defaults to `eng`. This mode requires OCRmyPDF, Tesseract, and Poppler's `pdfunite`.


