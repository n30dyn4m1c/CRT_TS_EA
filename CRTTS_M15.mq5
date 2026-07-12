//+------------------------------------------------------------------+
//|                                                    CRTTS_M15.mq5 |
//|                                                       Neo Malesa |
//|                                     https://www.x.com/n30dyn4m1c |
//+------------------------------------------------------------------+
#property copyright "Neo Malesa"
#property link      "https://www.x.com/n30dyn4m1c"
#property version   "1.03"

input ENUM_TIMEFRAMES TimeFrame = PERIOD_M15;
input double WickFactor = 3.0;   // wick must exceed this multiple of the body

// List of instruments (symbols) to loop through
string symbols[] = {
    "EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD",
    "EURJPY", "EURGBP", "EURCHF", "EURCAD", "EURAUD", "EURNZD",
    "GBPJPY", "GBPCHF", "GBPCAD", "GBPAUD", "GBPNZD",
    "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD",
    "CADCHF", "CADJPY", "CHFJPY",
    "NZDCAD", "NZDCHF", "NZDJPY",
    "AUS200Cash", "BRENTCash", "CA60Cash", "China50Cash", "ChinaHCash", "EU50Cash", "FRA40Cash",
    "GER40Cash", "HK50Cash", "IT40Cash", "JP225Cash", "NETH25Cash", "NGASCash", "OILCash",
    "SA40Cash", "SPAIN35Cash", "SWI20Cash", "Sing30Cash", "UK100Cash", "US100Cash",
    "US2000Cash", "US30Cash", "US500Cash", "GerMid50Cash", "GerTech30Cash", "TaiwanCash",
    "BTCEUR", "BTCGBP", "BTCUSD", "ETHEUR", "ETHGBP", "ETHUSD",
    "GOLD", "SILVER", "XAUUSD", "XAUEUR", "XPDUSD", "XPTUSD"
};

datetime lastBarTime[];   // last closed bar already checked, per symbol

int OnInit() {
    ArrayResize(lastBarTime, ArraySize(symbols));
    for (int i = 0; i < ArraySize(symbols); i++) {
        SymbolSelect(symbols[i], true);   // ensure symbol is in Market Watch so data loads
        lastBarTime[i] = 0;
    }
    EventSetTimer(30);   // timer keeps scanning even when the chart symbol has no ticks
    Print("CRT_TS_M15_EA initialized.");
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
    EventKillTimer();
}

void OnTick() {}   // scanning is timer-driven

void OnTimer() {
    for (int i = 0; i < ArraySize(symbols); i++) {
        string symbol = symbols[i];
        if (Bars(symbol, TimeFrame) < 3) continue;

        // Evaluate each closed bar exactly once per symbol (no duplicate alerts)
        datetime barTime = iTime(symbol, TimeFrame, 1);
        if (barTime == 0 || barTime == lastBarTime[i]) continue;
        lastBarTime[i] = barTime;

        // Candle0: currently forming candle (entry reference)
        double o0 = iOpen(symbol, TimeFrame, 0);

        // Candle2: range candle
        double o2 = iOpen(symbol, TimeFrame, 2);
        double c2 = iClose(symbol, TimeFrame, 2);
        double h2 = iHigh(symbol, TimeFrame, 2);
        double l2 = iLow(symbol, TimeFrame, 2);

        // Candle1: false breakout (TS candle)
        double o1 = iOpen(symbol, TimeFrame, 1);
        double c1 = iClose(symbol, TimeFrame, 1);
        double h1 = iHigh(symbol, TimeFrame, 1);
        double l1 = iLow(symbol, TimeFrame, 1);

        bool c1Bull = c1 > o1;
        bool c1Bear = c1 < o1;
        bool c2Bull = c2 > o2;
        bool c2Bear = c2 < o2;

        if (!c1Bull && !c1Bear) continue;
        if (!c2Bull && !c2Bear) continue;

        double body1 = MathAbs(c1 - o1);
        double lowerWick1 = MathMin(o1, c1) - l1;
        double upperWick1 = h1 - MathMax(o1, c1);

        bool longLowerWick1 = lowerWick1 > WickFactor * body1;
        bool longUpperWick1 = upperWick1 > WickFactor * body1;

        int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

        // Bullish Turtle Soup
        if (c2Bear && c1Bull && l1 < l2 && c1 > c2 && longLowerWick1) {
            double entry = o0;
            double sl = l1;
            double tp1 = (l2 + h2) / 2.0;
            double tp2 = h2;
            Alert(symbol + " M15: Bullish Turtle Soup detected.");
            Alert(symbol + " Buy Below: " + DoubleToString(entry, digits) + " | SL: " + DoubleToString(sl, digits) + " | TP1: " + DoubleToString(tp1, digits) + " | TP2: " + DoubleToString(tp2, digits));
        }

        // Bearish Turtle Soup
        if (c2Bull && c1Bear && h1 > h2 && c1 < c2 && longUpperWick1) {
            double entry = o0;
            double sl = h1;
            double tp1 = (h2 + l2) / 2.0;
            double tp2 = l2;
            Alert(symbol + " M15: Bearish Turtle Soup detected.");
            Alert(symbol + " Sell Above: " + DoubleToString(entry, digits) + " | SL: " + DoubleToString(sl, digits) + " | TP1: " + DoubleToString(tp1, digits) + " | TP2: " + DoubleToString(tp2, digits));
        }
    }
}
