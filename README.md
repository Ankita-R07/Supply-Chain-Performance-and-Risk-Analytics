# Supply Chain Performance & Risk Analytics

An end-to-end data analytics project focused on delivery performance, shipping reliability, regional operational risk, and financial exposure in a supply chain dataset.

## Project Overview

Supply chain performance depends on more than the number of orders delivered. Understanding delivery delays, shipping duration variability, regional performance, and the financial value associated with delayed shipments can help businesses identify areas that need further investigation.

This project analyses the DataCo Smart Supply Chain dataset using Python, SQL, and Power BI. The aim is to turn raw order-level data into meaningful operational and financial insights through data auditing, analytical queries, and interactive dashboards.

## Business Objectives

- Evaluate delivery outcomes and identify late-delivery patterns.
- Measure shipping duration variance against scheduled shipping duration.
- Compare shipping reliability across shipping modes, regions, markets, and product categories.
- Analyse shipment volume alongside delivery reliability.
- Quantify sales and profit associated with delayed shipments.
- Build interactive dashboards to support data-driven operational decisions.

## Tools & Technologies

- **Python :** Data inspection, quality checks, cleaning, and preprocessing.
- **SQL (MySQL) :** Business analysis, aggregations, comparisons, and insight generation.
- **Power BI :** In teractive dashboards, KPI cards, trend analysis, and visual reporting.
- **Excel :** Supporting data inspection and analysis.

## Dataset

**Dataset :** DataCo Smart Supply Chain

The analysis uses the cleaned dataset containing 180,519 order-item records and 55 columns.

| Dataset characteristic | Value |
|---|---:|
| Order-item records | 180,519 |
| Distinct orders | 65,752 |
| Unique customers | 20,652 |
| Distinct products | 118 |
| Columns in cleaned dataset | 55 |

The dataset contains order, customer, product, shipping, delivery-status, sales, and profitability information.

The analytical grain is **one row per order item**. An order may therefore appear in multiple rows, so order counts and order-item counts are treated separately.

## Project Workflow

### 1. Data Audit and Preparation

- Inspected dataset structure, dimensions, data types, missing values, and duplicate records.
- Checked identifier consistency and date integrity.
- Reviewed financial reconciliation and calculated-field consistency.
- Prepared the cleaned dataset for SQL analysis and Power BI reporting.
- Retained valid negative profit values rather than automatically treating them as errors.

### 2. SQL Analysis

Created a structured set of SQL scripts covering:

1. Schema and table preparation
2. Overall delivery performance
3. Shipping-mode analysis
4. Geographic performance
5. Product-category analysis
6. Shipment volume versus reliability
7. Time-trend analysis
8. Financial exposure analysis
9. Consolidated business insights

### 3. Power BI Dashboard Development

Built a four-page interactive report with KPI cards, slicers, ranked comparisons, trend charts, scatter charts, and a financial performance matrix.

## Key Findings

The following baseline results were obtained with the report's default filters.

| Metric | Result |
|---|---:|
| Total order items | 180,519 |
| Total orders | 65,752 |
| Dataset-labelled late-delivery rate | 54.83% |
| Slower-than-scheduled shipment rate | 57.28% |
| Average shipping duration variance | +0.57 days |
| Total sales | 36.78M |
| Sales associated with delayed shipments | 21.03M |
| Profit associated with delayed shipments | 2.23M |

### Operational Findings

- The dataset's `Late delivery` status and the slower-than-scheduled shipment measure produce different rates and are analysed separately.
- Shipping-mode comparisons show substantial differences in shipping-duration performance.
- Regional comparisons highlight differences in slower-than-scheduled rates and the financial value associated with delayed shipments.
- Shipment volume is considered alongside reliability to distinguish high-volume operational exposure from high rates in smaller groups.

### Financial Findings

- Fishing recorded approximately 3.97M in sales associated with delayed shipments in the baseline analysis.
- Western Europe recorded approximately 3.45M in delayed sales exposure, followed by Central America at approximately 3.25M.
- Negative profit values were retained for investigation rather than automatically removed.
- The analysis treats delayed sales and delayed profit as associated exposure measures, not as confirmed lost revenue or profit caused by delays.

## Power BI Dashboard Pages

### Page 1 — Executive Overview

Provides a high-level summary of order volume, delivery outcomes, sales, delayed sales exposure, monthly order-item volume, shipping-mode exposure, and regional risk.

### Page 2 — Delivery Performance & Reliability

Examines delivery status, slower-than-scheduled shipments, shipping duration variance, monthly reliability trends, and delivery outcomes across shipping modes and customer segments.

### Page 3 — Geography & Shipping Analytics

Compares regional reliability, delayed sales exposure, shipment volume versus reliability, and market-level performance.

### Page 4 — Financial Exposure & Profitability

Analyses delayed sales exposure by product category, profit associated with delayed shipments, sales versus profit, category-level financial performance, and order volume versus financial exposure.

## Business Value

The project demonstrates how raw supply chain data can be transformed into structured analysis and interactive reporting. The findings can help analysts and operations teams identify areas for further investigation, compare performance across operational groups, and prioritise deeper analysis using both reliability and financial exposure.

These findings are descriptive and indicate associations and patterns; they do not establish causation.

## Important Analytical Considerations

- **Delivery status versus shipping duration :** `Delivery Status = 'Late delivery'` is used for the dataset-defined late-delivery rate. `Shipping Duration Variance > 0` is used for the slower-than-scheduled measure. They are not interchangeable.
- **Order-level versus item-level counts :** The dataset contains one row per order item. Repeated order IDs are expected and are not treated as duplicate records.
- **OTIF limitation :** On-Time In-Full is not calculated because the available dataset does not provide the required ordered-versus-fulfilled quantity information.
- **Carrier analysis limitation :** A suitable carrier field was not available for a reliable carrier-level comparison.
- **Financial interpretation :** Delayed sales exposure and delayed profit represent values associated with delayed shipments. They do not prove that the amounts were lost because of delays.
- **Time trends :** The observed shift in item volume and composition after September 2017 is treated as a source-data pattern requiring further investigation, not as a confirmed business downturn.

## Future Improvements

- Add predictive analysis for delivery-delay risk, subject to suitable feature and target validation.
- Develop deeper root-cause analysis using additional operational data.
- Incorporate carrier-level analysis if reliable carrier information becomes available.
- Explore time-based forecasting after investigating the observed data-composition shift.

## Author

**[Ankita Raje]**

Aspiring Data Analyst | Python | SQL | Power BI

---

*This project was developed as a portfolio project to demonstrate practical data auditing, SQL analysis, business interpretation, and interactive dashboard development.*