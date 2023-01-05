//+------------------------------------------------------------------+
//|                                                        Price.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
//--- structures

struct Price {
   double open;
   double close;
   double high;
   double low;
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Price add(Price &first,Price &second) {
   Price r;
   r.open   = first.open   + second.open;
   r.close  = first.close  + second.close;
   r.high   = first.high   + second.high;
   r.low    = first.low    + second.low;
   return r;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Price minues(Price &first,Price &second) {
   Price r;
   r.open   = first.open   - second.open;
   r.close  = first.close  - second.close;
   r.high   = first.high   - second.high;
   r.low    = first.low    - second.low;
   return r;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Price devide(Price &first,int divition) {
   Price r;
   r.open   = first.open   / divition;
   r.close  = first.close  / divition;
   r.high   = first.high   / divition;
   r.low    = first.low    / divition;
   return r;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Price multiply(Price &first,int multiplier) {
   Price r;
   r.open   = first.open   * multiplier;
   r.close  = first.close  * multiplier;
   r.high   = first.high   * multiplier;
   r.low    = first.low    * multiplier;
   return r;
}