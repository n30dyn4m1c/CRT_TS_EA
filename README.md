# CRT Turtle Soup EAs for MetaTrader 5

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-MetaTrader%205-blue.svg)](https://www.metatrader5.com/)
[![Language](https://img.shields.io/badge/Language-MQL5-orange.svg)](https://www.mql5.com/)
[![Strategy](https://img.shields.io/badge/Strategy-Candle%20Range%20Theory-green.svg)](https://github.com/n30dyn4m1c/crt-turtlesoup-ea)

**Multi-timeframe MetaTrader 5 Expert Advisors that detect Turtle Soup reversal setups across 60+ forex, index, commodity, and crypto instruments.**

Built for price-action traders who want clean, wick-based entries without indicators. Alert-only by default — no auto-trading yet.

## Features

- Detects 3-candle Turtle Soup setups (range → false breakout → reversal)
- Long wick validation: wick ≥ body × `WickFactor` (adjustable input)
- Trade level alerts on H4, H1, and M15: Entry, SL, TP1, TP2
- Multi-asset scanning from one chart (60+ symbols)
- Pure price action — no indicators
- One alert per closed bar per symbol (no duplicate spam)
- Timer-driven scanning — keeps working even if the chart symbol’s market is closed
- Auto-adds scanned symbols to Market Watch on init

## Turtle Soup Logic (H4, H1, M15)

Strict 3-candle pattern:

| Candle | Role |
|--------|------|
| Candle2 | Range candle |
| Candle1 | False breakout with a long wick |
| Candle0 | Currently forming (entry reference) |

**Trade levels**

- **Entry** — open of Candle0 (buy below / sell above)
- **SL** — wick extreme of Candle1
- **TP1** — midpoint of Candle2 range
- **TP2** — Candle2 extreme (opposite side of the setup)

**Bullish TS** — Candle2 bearish; Candle1 bullish, breaks Candle2 low, closes above Candle2 close, long lower wick  
**Bearish TS** — Candle2 bullish; Candle1 bearish, breaks Candle2 high, closes below Candle2 close, long upper wick

## Included Files

| File | Timeframe | Default wick | Trade alerts | Notes |
|------|-----------|--------------|--------------|-------|
| `CRTTS_M15.mq5` | M15 | ≥ 3× body | Yes | High-frequency setups |
| `CRTTS_H1.mq5` | H1 | ≥ 2× body | Yes | 3-candle logic + full alerts |
| `CRTTS_H4.mq5` | H4 | ≥ 2× body | Yes | 3-candle logic + full alerts |
| `CRTTS_Daily.mq5` | D1 | ≥ 2× body | No | Daily signal filter |
| `CRTTS_Weekly.mq5` | W1 | ≥ 2× body | No | Longer-term confirmation |
| `CRTTS_Monthly.mq5` | MN1 | ≥ 2× body | No | Macro-level reversals |
| `crt-ts.mq5` | Any | ≥ 3× body | Yes | Timeframe-selectable + 50% retrace filter |

Wick thresholds are defaults; each EA exposes a `WickFactor` input. All EAs are **alert-only** by default.

## Setup

1. Open MetaTrader 5 → **File → Open Data Folder** → copy the `.mq5` files into `MQL5/Experts/`.
2. Open MetaEditor (`F4`), compile each EA (`F7`).
3. In Navigator, drag an EA onto any chart and enable **Algo Trading**.
4. Alerts pop up when a valid pattern is detected on a closed bar.

## When to Run

| Timeframe | Suggested use |
|-----------|----------------|
| M15 | Continuously during active sessions |
| H1 | Around the open of each trading hour |
| H4 | Near the open of each H4 candle (e.g. NY 01:00, 05:00, 09:00) |
| Daily | After the daily open |
| Weekly | Mondays after the weekly open |
| Monthly | First trading day of the month |

## Screenshot

![Turtle Soup Alert](screenshot.png)

## Notes from Use

- Prefer large range candles; thin ranges are lower quality.
- A Turtle Soup candle that retraces more than ~50% of the range candle is often invalid.
- Prefer instruments with tight spreads; wide-spread names generate noisy signals.
- Symbols must be in Market Watch for scanning (the EAs auto-add their list on init).
- Non-24h markets only alert while the session is open.
- HTF premium/discount context pairs well with LTF Turtle Soup (e.g. Daily PD → H1 TS, H4 PD → M15 TS).

## Roadmap

- Timed H4 scans (first 30 minutes of each candle)
- Hard filter: TS body < 50% of range body
- Multi-candle range breaks (2–5 bars)
- Merged multi-timeframe EA with toggles
- Push / email / mobile notifications
- Optional auto-trading with SL/TP and position sizing
- On-chart signal dashboard

## Disclaimer

For educational and research use. Trading leveraged markets carries substantial risk of loss. Backtest and forward-test on demo before any live capital. Past performance is not indicative of future results.

## License

This project is licensed under the [MIT License](LICENSE).

## Author

**Neo Malesa** — [@n30dyn4m1c](https://x.com/n30dyn4m1c)  
Strategy inspired by Turtle Soup (Linda Raschke) and Candle Range Theory (Romeo).
