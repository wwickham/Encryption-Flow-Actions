import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import JS_PDF from '@salesforce/resourceUrl/jsPDF';

export default class JsPDFDocGen extends LightningElement {
    jsPDFInitialized = false;

  renderedCallback() {
    if (!this.jsPDFInitialized) {
      this.jsPDFInitialized = true;
      loadScript(this, JS_PDF)
        .then(() => {
          console.log('jsPDF library loaded successfully');
        })
        .catch((error) => {
          console.error('Error loading jsPDF library', error);
        });
    }
  }

  handleGeneratePDF() {
    if (this.jsPDFInitialized) {
      // Make sure to correctly reference the loaded jsPDF library.
      const doc = new window.jspdf.jsPDF();

      // Get page width to center text
      const pageWidth = doc.internal.pageSize.getWidth();
      const centerX = pageWidth / 2;

      // Line height spacing
      const lineHeight = 5;
      let y = 15; // starting Y position
      let x = 6;

      console.log(doc.getFontList());

      // First line (normal text)
      doc.setFont("helvetica", "normal");
      doc.setFontSize(10);
      doc.text("The University of the State of New York", centerX, y, { align: "center" });

      // Second line (bold text)
      y += lineHeight;
      doc.setFont("helvetica", "bold");
      doc.text("THE STATE EDUCATION DEPARTMENT", centerX, y, { align: "center" });

      y += lineHeight;
      doc.setFont("helvetica", "normal");
      doc.text("Office of Teaching Initiatives", centerX, y, { align: "center" });

      // Third line (link)
      y += lineHeight;
      doc.setTextColor(0, 0, 255); // blue link color

      const linkText = "www.highered.nysed.gov/tcert";

      doc.textWithLink(linkText, centerX, y, {
        url: "www.highered.nysed.gov/tcert",
        align: "center"
      });

      const textWidth = doc.getTextWidth(linkText);
      doc.setDrawColor(0, 0, 255);
      doc.line(centerX - textWidth / 2, y + 0.5, centerX + textWidth / 2, y );

      // Reset text color (in case you write more later)
      doc.setTextColor(0, 0, 0);
      doc.setDrawColor(0, 0, 0);

      y += 10;
      doc.setFont("helvetica", "bold");
      doc.setFontSize(12);
      doc.text("Completion of Approved Continuing Teacher and Leader Education (CTLE) Hour(s) Certificate", centerX, y, { align: "center" });

      y += 10;
      doc.setFont("helvetica", "normal");
      doc.setFontSize(10);
      doc.text("All CTLE must be completed with Approved Sponsors and be reported using this form, or an alternative form/format that captures the same information that is requested on this form, in addition to any electronic reporting requirements.", x + 2, y, { align: "left", maxWidth: 200 });

      const colWidths = [(pageWidth - 20) * 0.4, (pageWidth - 20) * 0.4, (pageWidth - 20) * 0.20]; // First row columns
      const rowHeight = 9;

      let startY = y + 20;

      // --- Section Header ---
      doc.setFillColor(200, 220, 255); // light blue background
      doc.rect(10, startY, pageWidth - 20, 6, "F"); // filled rect
      doc.rect(10, startY, pageWidth - 20, 6);
      doc.setFont("helvetica", "bold");
      doc.setFontSize(11);
      doc.text("Section I", 12, startY + 4);

      startY += 6;

      const labels = ["First Name:", "Last Name:", "Middle Initial:"];
      const values = [this.firstName, this.lastName, this.middleInitial];

      // --- First Row (3 columns) ---
      doc.setFont("helvetica", "normal");
      doc.setFontSize(9);
      x = 10;
      labels.forEach((label, i) => {
        doc.rect(x, startY, colWidths[i], rowHeight); // border
        doc.setFont("helvetica", "normal");
        doc.setFontSize(9);
        doc.text(label, x + 2, startY + 3);

        const labelWidth = doc.getTextWidth(label);

        doc.setFontSize(14);
        doc.text(values[i], x + 2 + labelWidth + 2, startY + 6);

        x += colWidths[i];
      });

      startY += rowHeight;

      // --- Second Row (2 columns) ---
      x = 10;
      const secondRowCols = [100, pageWidth - 20 - 100];
      ["Date of Birth:", "Last 4 Digits of the Social Security Number:"].forEach(
        (label, i) => {
          doc.rect(x, startY, secondRowCols[i], rowHeight); // border
          doc.text(label, x + 2, startY + 3);
          x += secondRowCols[i];
        }
      );

      doc.save("header-example.pdf");
    } else {
      console.error('jsPDF library not initialized');
    }
  }

firstName = "John";
lastName = "Smith";
middleInitial = "Q";

  drawField(label, value, doc) {
    doc.rect(20, y, this.fieldWidth, this.fieldHeight); // outer rectangle
    doc.text(`${label}: ${value}`, 25, y + 8); // text inside
    y += this.fieldHeight + 5; // move down
  }
}