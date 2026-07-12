//+------------------------------------------------------------------+
//|                                                       crt-ts.mq5 |
//|                                                       Neo Malesa |
//|                                     https://www.x.com/n30dyn4m1c |
//+------------------------------------------------------------------+
#property copyright "Neo Malesa"
#property link      "https://www.x.com/n30dyn4m1c"
#property version   "1.08"
#property strict

input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;
input int   Lookback=20;              // kept for data safety; not used in purge test
input bool  UseWickFilter=true;
input double WickFactor=3.0;

string symbols[] = {
  "EURUSD","USDJPY","GBPUSD","USDCHF","AUDUSD","USDCAD","NZDUSD",
  "EURJPY","EURGBP","EURCHF","EURCAD","EURAUD","EURNZD",
  "GBPJPY","GBPCHF","GBPCAD","GBPAUD","GBPNZD",
  "AUDCAD","AUDCHF","AUDJPY","AUDNZD",
  "CADCHF","CADJPY","CHFJPY",
  "NZDCAD","NZDCHF","NZDJPY",
  "AUS200Cash","BRENTCash","CA60Cash","China50Cash","ChinaHCash","EU50Cash","FRA40Cash",
  "GER40Cash","HK50Cash","IT40Cash","JP225Cash","NETH25Cash","NGASCash","OILCash",
  "SA40Cash","SPAIN35Cash","SWI20Cash","Sing30Cash","UK100Cash","US100Cash",
  "US2000Cash","US30Cash","US500Cash","GerMid50Cash","GerTech30Cash","TaiwanCash",
  "BTCEUR","BTCGBP","BTCUSD","ETHEUR","ETHGBP","ETHUSD",
  "GOLD","XAUUSD","XAUEUR","XPDUSD","XPTUSD"
};

datetime lastBarTime[];

//----------------- Helpers -----------------
bool WickPass(double o1,double c1,double h1,double l1,bool bull,double factor){
  double body=MathAbs(c1-o1); if(body<=0) return false;
  double lower=MathMin(o1,c1)-l1, upper=h1-MathMax(o1,c1);
  return bull ? (lower>=factor*body) : (upper>=factor*body);
}
// Signal bar must be strictly below/above 50% of prior bar
bool MidNotReachedBull(const MqlRates &r[]){
  double mid=(r[1].high + r[1].low)*0.5;
  return (r[0].high < mid);
}
bool MidNotReachedBear(const MqlRates &r[]){
  double mid=(r[1].high + r[1].low)*0.5;
  return (r[0].low > mid);
}

//----------------- Pattern functions -----------------
// Bullish TS (TS+1): bar0 purges PRIOR LOW (r[1].low) and closes back above it.
bool isBullishTurtleSoup(const MqlRates &r[],bool useWick,double wickFactor){
  double o1=r[0].open,c1=r[0].close,h1=r[0].high,l1=r[0].low;
  double l2=r[1].low;
  if(!(c1>o1)) return false;                         // bullish body
  if(!(l1<l2 && c1>l2)) return false;                // purge prior low, close above it
  if(useWick && !WickPass(o1,c1,h1,l1,true,wickFactor)) return false; // long lower wick
  if(!MidNotReachedBull(r)) return false;            // high < 50% of prior range
  return true;
}
// Bearish TS (TS+1): bar0 purges PRIOR HIGH (r[1].high) and closes back below it.
bool isBearishTurtleSoup(const MqlRates &r[],bool useWick,double wickFactor){
  double o1=r[0].open,c1=r[0].close,h1=r[0].high,l1=r[0].low;
  double h2=r[1].high;
  if(!(c1<o1)) return false;                         // bearish body
  if(!(h1>h2 && c1<h2)) return false;                // purge prior high, close below it
  if(useWick && !WickPass(o1,c1,h1,l1,false,wickFactor)) return false; // long upper wick
  if(!MidNotReachedBear(r)) return false;            // low > 50% of prior range
  return true;
}

//----------------- Core check -----------------
void CheckSymbol(const int idx,ENUM_TIMEFRAMES tf){
  string sym=symbols[idx];
  if(Bars(sym,tf) < 50) return;                      // data safety

  datetime t=iTime(sym,tf,1);                        // closed bar only
  if(t==0 || t==lastBarTime[idx]) return;

  MqlRates rr[];
  ArraySetAsSeries(rr,true);                         // rr[0]=last closed bar, rr[1]=prior bar
  if(CopyRates(sym,tf,1,Lookback+5,rr) < 2) return;  // need bar0 & bar1 at least
  lastBarTime[idx]=t;                                // mark handled only after data is in

  int digits=(int)SymbolInfoInteger(sym,SYMBOL_DIGITS);
  double h2=rr[1].high, l2=rr[1].low;

  if(isBullishTurtleSoup(rr,UseWickFilter,WickFactor)){
    double entry=iOpen(sym,tf,0), sl=rr[0].low, tp1=(l2+h2)*0.5, tp2=h2;
    Alert(sym+" "+EnumToString(tf)+": Bullish Turtle Soup | Entry "+DoubleToString(entry,digits)
          +" SL "+DoubleToString(sl,digits)
          +" TP1 "+DoubleToString(tp1,digits)
          +" TP2 "+DoubleToString(tp2,digits));
  }
  if(isBearishTurtleSoup(rr,UseWickFilter,WickFactor)){
    double entry=iOpen(sym,tf,0), sl=rr[0].high, tp1=(h2+l2)*0.5, tp2=l2;
    Alert(sym+" "+EnumToString(tf)+": Bearish Turtle Soup | Entry "+DoubleToString(entry,digits)
          +" SL "+DoubleToString(sl,digits)
          +" TP1 "+DoubleToString(tp1,digits)
          +" TP2 "+DoubleToString(tp2,digits));
  }
}

//----------------- EA lifecycle -----------------
int OnInit(){
  ArrayResize(lastBarTime,ArraySize(symbols));
  for(int i=0;i<ArraySize(symbols);i++){ SymbolSelect(symbols[i],true); lastBarTime[i]=0; }
  EventSetTimer(2);                                  // run post-close only
  return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){ EventKillTimer(); }
void OnTimer(){
  ENUM_TIMEFRAMES tf=(TimeFrame==PERIOD_CURRENT?(ENUM_TIMEFRAMES)_Period:TimeFrame);
  for(int i=0;i<ArraySize(symbols);i++) CheckSymbol(i,tf);
}
void OnTick(){} // avoid mid-bar checks
