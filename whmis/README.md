# WHMIS and transport safety terms

[Masterlist TXT](masterlist.txt) · [Masterlist TSV](masterlist.tsv)

| List | Files |
| --- | --- |
| Transport and workplace hazard labels in English and French | [TXT](hazard-labels.txt) · [TSV](hazard-labels.tsv) |
| PPE, first aid and emergency equipment | [TXT](workplace-safety.txt) · [TSV](workplace-safety.tsv) |

Use these terms to find safety data sheets, shipping notices and workplace records. The TSV retains a source for each term. For an exact product already identified in an order or shipment, check the supplier’s safety data sheet. Section 2 describes the hazards. Section 14 can contain transport information. [Transport Canada labels](https://tc.canada.ca/en/dangerous-goods/safety-awareness-materials-faq/industry/dangerous-goods-marks/dangerous-goods-marks-classes-description) · [CCOHS Safety Data Sheets](https://www.ccohs.ca/oshanswers/chemicals/whmis_ghs/sds.html)

Use Ctrl+F with the TXT files, or run from the extracted kit root.

```powershell
.\Find-WordList.ps1 -WordListPath '.\whmis\masterlist.tsv' -DocumentPath 'C:\CaseWork\shipping-export.txt' -OutputPath 'C:\CaseWork\whmis-hits.csv' -WholeWord
```
