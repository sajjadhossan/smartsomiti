# PREDICTIVE ANALYTICS & STATISTICAL FORECASTING SPECIFICATION

## 1. Principles of Predictive Integrity
1. **No Data Fabrication**: Forecasts are computed strictly when sufficient historical data ($\ge 30$ continuous daily or $\ge 6$ monthly datapoints) exists.
2. **Defensive Insufficient Data Fallback**: When records are sparse, the system explicitly responds:
   - *"ভবিষ্যদ্বাণীর জন্য পর্যাপ্ত ঐতিহাসিক তথ্য নেই (Insufficient data for reliable forecasting)।"*
3. **Transparent Uncertainty Bounds**: Every forecast displays a $95\%$ Confidence Interval ($[\text{Lower}, \text{Upper}]$).

## 2. Supported Forecasting Targets & Mathematical Models
- **Cash Flow & Installment Collection Forecast**:
  - Model: Triple Exponential Smoothing (Holt-Winters) accounting for monthly collection cycle seasonality.
- **Member Savings Growth**:
  - Model: Linear Trend with Autoregressive Error ($AR(1)$).
- **Subscription MRR / Churn Prediction**:
  - Model: Logistic Regression over renewal activity and activity decay metrics.

```mermaid
graph LR
    History[(Historical General Ledger & Transactions)] --> QualityCheck{Data Points >= 30?}
    QualityCheck -->|No| Fallback[Output: Insufficient Data Alert]
    QualityCheck -->|Yes| ModelRunner[Run Forecasting Algorithm]
    ModelRunner --> Intervals[Compute 95% Confidence Bounds]
    Intervals --> Backtest[Compute Error Metric MAE / MAPE]
    Backtest --> Presentation[Render Forecast Chart with Verified Bounds]
```

## 3. Backtesting & Accuracy Monitoring
Each forecast run stores its Mean Absolute Error (MAE) and Mean Absolute Percentage Error (MAPE):
$$\text{MAPE} = \frac{1}{n} \sum_{t=1}^{n} \left| \frac{A_t - F_t}{A_t} \right| \times 100\%$$
Where $A_t$ is actual historical reality and $F_t$ was the forecasted prediction.
