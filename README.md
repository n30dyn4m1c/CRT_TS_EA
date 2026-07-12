# 🐢🍲 Turtle Soup Detection EAs for MT5

A multi-timeframe MetaTrader 5 EA suite for detecting high-probability Turtle Soup reversal setups across over 60 forex, index, commodity, and crypto instruments. Developed for price action traders who seek clean, structured, wick-based entries without indicators.

---

## 🧰 Tech Stack

- **Platform**: MetaTrader 5
- **Language**: MQL5
- **Alert System**: Terminal-based alerts (planned: push/email)
- **Trade Logic**: Price-action, Turtle Soup reversal strategy
- **Symbol Coverage**: 60+ FX pairs, indices, metals, crypto
- **Timeframes**: M15, H1, H4, D1, W1, MN1

---

## 🚀 Key Features

- ✅ Detects 3-candle Turtle Soup setups (range → false breakout → reversal)
- ✅ Long wick validation: wick ≥ 2× body (adjustable via `WickFactor` input)
- ✅ Trade level alerts on H4, H1, & M15: Entry, SL, TP1, TP2
- ✅ Multi-asset scanning from one chart
- ✅ Pure price-action: no indicators used
- ✅ One alert per closed bar per symbol (per-symbol memory, no duplicate alerts)
- ✅ Timer-driven scanning: keeps working even if the chart symbol's market is closed
- ✅ Auto-adds all scanned symbols to Market Watch on init
- 🔜 Push/email/mobile alerts
- 🔜 Auto-trading logic with risk controls
- 🔜 On-chart dashboard for signal display

---

## 📊 Turtle Soup Logic (H4, H1, M15 EA)

The H4, H1, & M15 scripts follow strict 3-candle logic:
- **Candle2**: Range candle
- **Candle1**: False breakout candle with a long wick
- **Candle0**: Currently forming candle (entry reference)

### Trade Levels
- **Entry**: Open of Candle0 (Buy Below / Sell Above)
- **SL**: Wick extreme of Candle1
- **TP1**: Midpoint of Candle2 range
- **TP2**: Candle2 extreme (opposite direction of the setup)

### Detection Conditions
- **Bullish TS**:
  - Candle2 is bearish
  - Candle1 is bullish and breaks Candle2 low
  - Candle1 closes above Candle2 close
  - Candle1 has a long lower wick

- **Bearish TS**:
  - Candle2 is bullish
  - Candle1 is bearish and breaks Candle2 high
  - Candle1 closes below Candle2 close
  - Candle1 has a long upper wick

---

## 🗂 Included Files

| File                | Timeframe | Wick Requirement | Trade Alerts | Notes                          |
|---------------------|-----------|------------------|---------------|--------------------------------|
| `CRTTS_M15.mq5`     | M15       | ≥ 3× body        | Yes           | For high-frequency setups      |
| `CRTTS_H4.mq5`      | H4        | ≥ 2× body        | Yes           | 3-candle logic + full alerts   |
| `CRTTS_H1.mq5`      | H1        | ≥ 2× body        | Yes           | 3-candle logic + full alerts   |
| `CRTTS_Daily.mq5`   | D1        | ≥ 2× body        | No            | Clean daily signal filter      |
| `CRTTS_Weekly.mq5`  | W1        | ≥ 2× body        | No            | Long-term signal confirmation  |
| `CRTTS_Monthly.mq5` | MN1       | ≥ 2× body        | No            | Macro-level reversals          |
| `crt-ts.mq5`        | Any       | ≥ 3× body        | Yes           | Timeframe-selectable variant with 50% retrace filter |

Wick requirements above are defaults; each EA exposes a `WickFactor` input.

> All EAs are alert-only by default. No auto-trading yet.


---

## 🛠️ Setup Instructions

1. Open MetaTrader 5  
2. Press `F4` to open MetaEditor  
3. Copy `.mq5` files into the `MQL5/Experts` directory  
4. Compile your EA (`Right-click → Compile`)  
5. Open MT5 → Navigator → Drag the EA onto any chart  
6. Enable **Algo Trading**  
7. Wait for alerts (pop-up) when a valid pattern is detected

---

## ⏰ When to Run

- **M15**: Continuously during active sessions
- **H4**: NY time – 1 AM, 5 AM, 9 AM or PM
- **H1**: At the start of every trading hour
- **Daily**: At the start of the trading day
- **Weekly**: Mondays after weekly open
- **Monthly**: First calendar day of the month

---

## 📸 Screenshot

![Turtle Soup Alert](screenshot.png)

---

## 🎓 Lessons Learned

- 3-candle CRTs are easier to encode. Multiple candle CRT setups will need additional logic
- Size of the range candle needs to be big
- Backtest on demo first for at least a week
- Filter out only high quality CRT & TS setups, ignore low quality setups
- Consider removing instruments with large spread
- Consider first entry above/below range candle high/low, and second entry above/below current candle open
- Turtle soup candle should not reach more than 50% of range candle, then it is invalid
- Note instruments that do not trade 24 hours, EA will not trigger if market is closed.
- Also if loaded in a live isntrument, EA will continuously give alert for an instrument if market closed with a setup formation
- Only valid range is a thick down-closed or thick up-closed candle
- EA might need instrument to be opened in Market Watch, for it to scan, so open all

Relationship between Range Candle (RC) and Turtle Soup Candle (TSC)
- For RC body incl wick must be larger than TSC body incl wick, let's say 2x
- TSC must not reach 50% and 100% CR after TS
- Check IRL-ERL confluence when a TS is detected
- Valid TS sweeps a high or a low
- Entry models: LTF CISD

- Timeframe alignment for HTF Premium/Discount Array to LTF TS
- Monthly PD array - Daily TS
- Weekly PD array - 4H TS
- Daily PD array -  1H TS
- 4H PD array - 15M TS

---

## 🎯 Future Improvements

- Timed trigger: H4 scans only during first 30 min of each candle
- Filter: Require TS body < 50% of range body
- Expand logic to multi-candle range breaks (2–5 bars)
- Same-direction Turtle Soup (e.g. bullish candle + bullish wick)
- Merge timeframes into one EA with toggle switches
- Add dashboard with HTMX-style signal display
- Push/email/mobile notifications
- Add trading logic with SL/TP and lot sizing

---

## 📝 License & Acknowledgments

- © 2025 **Neo Malesa** – [@n30dyn4m1c on X](https://www.x.com/n30dyn4m1c)  
- Built with 💚 for MT5 CRT traders   
- Strategy inspired by Turtle Soup, coined by Linda Raschke, and Candle Range Theory by Romeo

---

