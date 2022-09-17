//+------------------------------------------------------------------+
//|                                                 MQL4Tutorial.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
datetime ArrayTime[], LastTime;
int lastIndex;
int limit =0;
class Position {
public:
   double            hh;
   double            ll;
   int               crossHH;
   int               crossLL;
   bool              isOpen;
   void              print();
   int               getStatus();
};
void Position::print(void) {
   Print("hh: "+ hh+" ll: +"+ll+" crossHH: "+crossHH+" crossLL: "+crossLL);
}
int Position::getStatus(void) {
   if(crossHH>2) {
      return 1;
   } else if(crossLL>2) {
      return -1;
   }
   return 0;
}

Position positions[10000000];
int OnInit() {
   Print(__FUNCTION__);
   lastIndex=0;
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
   Print(__FUNCTION__);
}
void OnTick() {
   if(NewBar(_Period)) {


      // update open positions SL

      //    if(OrdersTotal()>0)
      //    {
      //   double tenkanSL= iIchimoku(NULL,0,9,26,9,MODE_TENKANSEN,1);
      //                  for(int i=0; i<OrdersTotal(); i++)
      // {
      //         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      //       OrderModify(OrderTicket(),OrderOpenPrice(),tenkanSL,OrderTakeProfit(),0,clrNONE);
      //    }
      //   }

      // update positions HH and LL cross' with price
      for(int i=0; i<lastIndex; i++) {
         if(positions[i].isOpen) {
            continue;
         }
         double hh = positions[i].hh;
         double ll = positions[i].ll;
//         double ave1 = getAve(Open[0],Close[0]);
//         double ave2 = getAve(Open[1],Close[1]);
//
//         if((ave2 >= hh && ave1 <= hh)||(ave2<=hh && ave1>=hh && ave1> ave2)) {
//            Print("recognize new cross for position at HH");
//            positions[i].print();
//            Print("hh:"+hh);
//            Print("ave1:"+ave1);
//            Print("ave2:"+ave2);
//            positions[i].crossHH+=1;
//         }
//
//         if((ave2 >= ll && ave1 <= ll && ave2> ave1)||(ave2<=ll && ave1>=ll && ave1> ave2)) {
//            Print("recognize new cross for position at LL");
//            positions[i].print();
//            Print("ll:"+ll);
//            Print("ave1:"+ave1);
//            Print("ave2:"+ave2);
//            positions[i].crossLL+=1;
//         }
         double open = Open[1];
         double close = Close[1];
         if((open >= hh && close <= hh)||(open<=hh && close>=hh)) {
            Print("recognize new cross for position at HH");
            Print("hh:"+hh);
            Print("open:"+open);
            Print("close:"+close);
            positions[i].crossHH+=1;
            positions[i].print();
         }

         if((open >= ll && close <= ll)||(open<=ll && close>=ll)) {
            Print("recognize new cross for position at LL");
            Print("ll:"+ll);
            Print("open:"+open);
            Print("close:"+close);
            positions[i].crossLL+=1;
            positions[i].print();
         }

      }
      for(int i=0; i<lastIndex; i++) {
         if(positions[i].isOpen) {
            continue;
         }

         double hh = positions[i].hh;
         double ll = positions[i].ll;
         int status = positions[i].getStatus();
         double vol = 0.01;
         if (status == 1 || status == -1){
         int OP_Type = int(0.5 * ( ((1+status)*OP_BUY) + ((1-status)*OP_SELL) ));
         int mSLS = MarketInfo(Symbol(),MODE_STOPLEVEL);
         color COL[2] = {clrBlue,clrRed};
         color COLOR = COL[OP_Type];
         double OOP =  (0.5*((1+status)*Ask+(1-status)*Bid));
         double tp;
         double sl;
         if(status ==1)
           {
            tp = (hh + (getDiff(hh,ll)/2));
            sl = (hh - (getDiff(hh,ll)/2));
           }else{
           tp = (ll- (getDiff(hh,ll)/2));
           sl = (ll+ (getDiff(hh,ll)/2));
           }

         if (sl <= mSLS) // I set my sl as the minimum allowed
           {
             sl = 1 + mSLS;
           }
         double SLP =  OOP - status * sl * Point;
         if (tp <= mSLS) // I set my tp as the minimum allowed
           {
             tp = 1 + mSLS;
           }
         double TPP =  OOP + status * tp * Point;
         float ls = 0.01;
         int slip = 3; //(pips)
         Print("Try to open a position !!!");
         Print("OOP: "+OOP);
         Print("SLP: "+SLP);
         Print("TPP: "+TPP);
         int order = OrderSend(Symbol(),OP_Type,ls,OOP,slip,SLP,TPP,"",0,0,COLOR);
         positions[i].isOpen=true;

/*
            if(status==1) {
                OrderSend(Symbol(),OP_BUY,vol,Ask,3,(hh - (getDiff(hh,ll)/2)),(hh + (getDiff(hh,ll)/2)),"",0,0,clrBlue);
                positions[i].isOpen=true;
            } else if(status == -1) {
                OrderSend(Symbol(),OP_SELL,vol,Bid,3,(ll+ (getDiff(hh,ll)/2)),(ll- (getDiff(hh,ll)/2)),"",0,0,clrRed);
                positions[i].isOpen=true;
            }
  */
         }

      }

      if(isTenKenCrossKijunAtShift(1)&& (!isCrossedDuringShift(19))) {
        Print("find new position and close[1] is: ");
         Print(Close[1]);
         double hPrice = getHH(19);
         double lPrice = getLL(19);
         Print("last 19 hh is Price: " + hPrice);
         Print("last 19 ll is price: " + lPrice);
         positions[lastIndex].crossHH=0;
         positions[lastIndex].crossLL=0;
         positions[lastIndex].hh=hPrice;
         positions[lastIndex].ll=lPrice;
         positions[lastIndex].isOpen=false;
         lastIndex+=1;

      }
   }

//  limit++;
//  if(limit ==20)
//    {
//     limit=0;
//    }
// }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isTenKenCrossKijunAtShift(int shift) {
   double tenkan1= iIchimoku(NULL,0,9,26,9,MODE_TENKANSEN,shift);
   double  kijun1 =  iIchimoku(NULL,0,9,26,9,MODE_KIJUNSEN,shift);

   double tenkan2= iIchimoku(NULL,0,9,26,9,MODE_TENKANSEN,shift+1);
   double  kijun2 =  iIchimoku(NULL,0,9,26,9,MODE_KIJUNSEN,shift+1);

   if((tenkan2 >= kijun2 && tenkan1 <= kijun1)||(tenkan2 <= kijun2 && tenkan1 >= kijun1)) {
      return true;
   } else {
      return false;
   }
}
//+------------------------------------------------------------------+
//|                           get average of candle                                       |
//+------------------------------------------------------------------+
double getAve(double open, double close) {
   return (open+close)/2;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isCrossedDuringShift(int shift) {
   for(int i=2; i<=shift+2; i++) {
      if(isTenKenCrossKijunAtShift(i)) {
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar(int period) {
   bool firstRun = false, newBar = false;

   ArraySetAsSeries(ArrayTime,true);
   CopyTime(Symbol(),period,0,2,ArrayTime);

   if(LastTime == 0)
      firstRun = true;
   if(ArrayTime[0] > LastTime) {
      if(firstRun == false)
         newBar = true;
      LastTime = ArrayTime[0];
   }
   return newBar;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getHH(int count) {
   int shiftClose = iHighest(_Symbol,PERIOD_CURRENT,MODE_CLOSE,count,0);
   int shiftOpen = iHighest(_Symbol,PERIOD_CURRENT,MODE_OPEN,count,0);
   return MathMax(Close[shiftClose],Open[shiftOpen]);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLL(int count) {
   int shiftClose = iLowest(_Symbol,PERIOD_CURRENT,MODE_CLOSE,count,0);
   int shiftOpen = iLowest(_Symbol,PERIOD_CURRENT,MODE_OPEN,count,0);
   return MathMin(Close[shiftClose],Open[shiftOpen]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getDiff(double hh, double ll) {
   return hh-ll;
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0) {       // priority for mouse click
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
   }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
//| Move horizontal line                                             |
//+------------------------------------------------------------------+
bool HLineMove(const long   chart_ID=0,   // chart's ID
               const string name="HLine", // line name
               double       price=0) {    // line price
//--- if the line price is not set, move it to the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move a horizontal line
   if(!ObjectMove(chart_ID,name,0,0,price)) {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
   }
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
//| Delete a horizontal line                                         |
//+------------------------------------------------------------------+
bool HLineDelete(const long   chart_ID=0,   // chart's ID
                 const string name="HLine") { // line name
//--- reset the error value
   ResetLastError();
//--- delete a horizontal line
   if(!ObjectDelete(chart_ID,name)) {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
   }
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
