"""Opens the docx in Word, updates all fields (TOC, page numbers), saves it
back, and exports a PDF with those fields already resolved."""
import os
import win32com.client as win32

HERE = os.path.dirname(os.path.abspath(__file__))
docx_path = os.path.join(HERE, "Colombo_Eats_Report.docx")
pdf_path = os.path.join(HERE, "Colombo_Eats_Report.pdf")

word = win32.gencache.EnsureDispatch("Word.Application")
word.Visible = False
doc = word.Documents.Open(docx_path)
doc.Fields.Update()
try:
    for toc in doc.TablesOfContents:
        toc.Update()
except Exception as e:
    print("TOC update warning:", e)
doc.Fields.Update()
doc.Repaginate()
doc.Save()
doc.ExportAsFixedFormat(OutputFileName=pdf_path, ExportFormat=17)  # wdExportFormatPDF
doc.Close(False)
word.Quit()
print("Updated and exported:", pdf_path)
