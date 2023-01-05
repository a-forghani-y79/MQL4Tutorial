//+------------------------------------------------------------------+
//|                                                 MQL4Tutorial.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property strict
#include <Price.mqh>
#include <PivotPoint.mqh>
#include <PriceChunk.mqh>
#include <Scanner.mqh>
#include <Level.mqh>

#include <HLine.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input int checkFrom = 4;
input int checkUntil = 100;
input double scoreVolumeMin =1;
input double scoreVolumeMax =100;
input int initLevelCount = 100;






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


int scannerRatioArray[] = {10};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+





//--- global variables

Price minPrice;
Price maxPrice;
PivotPoint pivotPointArray[];
int indexPivotTypeArray=0;


Scanner scannerArray[];
int indexScanner=0;


Level levelArray[];
int indexLevel=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void appendLevelArray(Level &s) {
   ArrayResize(levelArray,ArraySize(levelArray)+1);
   levelArray[indexLevel++]=s;

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void appendScannerArray(Scanner &s) {
   ArrayResize(scannerArray,ArraySize(scannerArray)+1);
   scannerArray[indexScanner++]=s;

};



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void appendPivotPointToArray(PivotPoint &pivotPoint) {
   ArrayResize(pivotPointArray,ArraySize(pivotPointArray)+1);
   pivotPointArray[indexPivotTypeArray++]=pivotPoint;
}



datetime ArrayTime[], LastTime;
int lastIndex;
int limit =0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   Print(__FUNCTION__);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init() {
   Print(__FUNCTION__);


   if(GetLastError()<0) {
      Print("Preparing Done. Let's Go !");
   } else {
      Print(GetLastError());
   }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Price getSpreadPrice(Price &fMinPrice, Price &fMaxPrice, int count,int indexfromCount) {
   Price diff = maxPrice.diff(minPrice);
   Price part = diff.devide(count);
   Price res = fMinPrice.add(part.multiply(indexfromCount));
   return res;
}
void allClear() {

   ObjectsDeleteAll(0);

   ArrayFree(pivotPointArray);
   indexPivotTypeArray=0;


   ArrayFree(scannerArray);
   indexScanner=0;


   ArrayFree(levelArray);
   indexLevel=0;
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {


   allClear();


   Print("Preparing Scanners ...");
   for(int i=0; i<ArraySize(scannerRatioArray); i++) {
      Print("for Ratio : "+IntegerToString(scannerRatioArray[i]));
      appendScannerArray(Scanner(checkFrom,checkUntil,scannerRatioArray[i]));
   }
   // create a line for begining of checking value;
   VLineCreate(0,StringConcatenate("Vline ","Start: "+IntegerToString(checkFrom)),0,Time[checkFrom],clrWhite);
   VLineCreate(0,StringConcatenate("Vline ","until: "+ IntegerToString(checkUntil)),0,Time[checkUntil],clrWhite);


   maxPrice = Price(iHighest(IntegerToString(0),NULL,MODE_CLOSE,checkUntil-checkFrom+1,checkFrom));
   minPrice = Price(iLowest(IntegerToString(0),NULL,MODE_CLOSE,checkUntil-checkFrom+1,checkFrom));


   int indexHighestVolume = getHighestLowestVolumeIndex(checkFrom,checkUntil,1);
   int indexLowestVolume  = getHighestLowestVolumeIndex(checkFrom,checkUntil,0);
   int type=0;

   for(int i=checkFrom; i<checkUntil-1; i++) {
      // check is it a pivot with type top or bottom
      //Print("price for candle index : "+IntegerToString(i)+" is "+DoubleToStr(getVolumeScore(i,indexLowestVolume,indexHighestVolume)));

      type = getPivotPointType(i);
      if(type ==TO_HIGH) {
         appendPivotPointToArray(PivotPoint(i,_Period,getVolumeScore(i,indexLowestVolume,indexHighestVolume),TO_HIGH));
         // VLineCreate(0,StringConcatenate("Vline ",IntegerToString(i)),0,Time[i],clrRed);
         ObjectCreate(IntegerToString(i), OBJ_TEXT, 0, Time[i],High[i]+2);
         ObjectSetDouble(0,IntegerToString(i),OBJPROP_ANGLE,90);
         ObjectSetText(IntegerToString(i),"i:"+IntegerToString(i)+" "+ DoubleToStr(getVolumeScore(i,indexLowestVolume,indexHighestVolume),2), 11, "Arial", clrRed);
      } else if(type ==-1) {
         //VLineCreate(0,StringConcatenate("Vline ",IntegerToString(i)),0,Time[i],clrBlue);
         appendPivotPointToArray(PivotPoint(i,_Period,getVolumeScore(i,indexLowestVolume,indexHighestVolume),TO_LOW));
         ObjectCreate(IntegerToString(i), OBJ_TEXT, 0, Time[i],Low[i]-2);
         ObjectSetDouble(0,IntegerToString(i),OBJPROP_ANGLE,90);
         ObjectSetText(IntegerToString(i),"i:"+IntegerToString(i)+" "+ DoubleToStr(getVolumeScore(i,indexLowestVolume,indexHighestVolume),2), 11, "Arial", clrGreenYellow);
      }

   }


   for(int i=0; i<ArraySize(scannerArray); i++) {
      for(int j=0; j<scannerArray[i].ratio; j++) {
         scannerArray[i].appendPriceChunk(PriceChunk(getSpreadPrice(minPrice,maxPrice,scannerArray[i].ratio,j),getSpreadPrice(minPrice,maxPrice,scannerArray[i].ratio,j+1)));
      }
   }

   for(int i=0; i<ArraySize(scannerArray); i++) {

      for(int j=0; j<ArraySize(scannerArray[i].priceChunkArray); j++) {
         //Print("checking for chunk: "+scannerArray[i].priceChunkArray[j].toString());
         for(int k=0; k<ArraySize(pivotPointArray); k++) {
            //Print(pivotPointArray[k].toString());
            if(isPriceInsidePriceChunk(pivotPointArray[k].price,scannerArray[i].priceChunkArray[j])) {
               //Print("found a pivot for chunk");
               scannerArray[i].priceChunkArray[j].appendPivotPoint(pivotPointArray[k]);
            }
         }
      }
   }

   // initialize leves
   for(int i=0; i<=initLevelCount; i++) {
      appendLevelArray(Level(getSpreadPrice(minPrice,maxPrice,initLevelCount,i),getSpreadPrice(minPrice,maxPrice,initLevelCount,i+1)));

   }



   for(int i=0; i<ArraySize(levelArray); i++) {
      Print(levelArray[i].toString());
      drawLevel(i,levelArray[i]);
   }




   // seperate chunks and initilize them

   //check pivot points and place in currect position inside chunks


   //Print("Price Chuank Array size : "+IntegerToString(ArraySize(priceChunkArray)));
   //for(int i=0; i<ArraySize(priceChunkArray); i++) {
   //   Print(PriceChunkToString(priceChunkArray[i]));
   //}


   // }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawLevel(int _index,Level& _level) {

   HLineCreate(0,"Level "+_index+" from",0,_level.from.close,clrWhite,0,2);
   HLineCreate(0,"Level "+_index+" until",0,_level.until.close,clrWhite,0,2);

   string data = "";

   for(int i=0; i<ArraySize(scannerArray); i++) {
      data = data + "["+scannerArray[i].ratio+":"+DoubleToStr(getLevelScoreInScanner(_level,scannerArray[i]),1)+"]";
   }


   ObjectCreate(0,"level value "+_index, OBJ_TEXT, 0, Time[1]+9000,((_level.from.close+_level.until.close)/2));
   // ObjectSetDouble(0,IntegerToString("level value "+_index),OBJPROP_ANGLE,90);
   ObjectSetText("level value "+_index,data, 11, "Arial", clrGreenYellow);

};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLevelScoreInScanner(Level& level, Scanner& scanenr) {
   int ratio = scanenr.ratio;
   double score =0;
   for(int i=0; i<ArraySize(scanenr.priceChunkArray); i++) {
      score+=getLevelScoreInPriceChunk(level,scanenr.priceChunkArray[i]);
   }
   return score;
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLevelScoreInPriceChunk(Level& _level,PriceChunk& _priceChunk) {
   double score =0;
   //todo
   if(isPriceInsideRange(_level.from,_priceChunk.from,_priceChunk.until)
         || (isPriceInsideRange(_priceChunk.from,_level.from,_level.until) && isPriceInsideRange(_priceChunk.until,_level.from,_level.until))
         || isPriceInsideRange(_level.until,_priceChunk.from,_priceChunk.until)) {
      score=_priceChunk.score;

   } else {
      score =0;
   }
   // Print(+score+"->"+_level.toString()+"->"+_priceChunk.toString());


   return score;
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isPriceInsidePriceChunk(Price& _price, PriceChunk& _priceChunk) {
   return (_price.close <= _priceChunk.until.close && _price.close >= _priceChunk.from.close);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isPriceInsideRange(Price& _price,Price& _from,Price& _until) {
   return _price.lessThen(_until) && _price.gratherThen(_from);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BankersRound(double value, int precision) {
   value = value * MathPow(10, precision);
   if (MathCeil(value) - value == 0.5 && value - MathFloor(value) == 0.5) {   // also could use: MathCeil(value) - value == value - MathFloor(value)
      if (MathMod(MathCeil(value), 2) == 0) {
         return (MathCeil(value) / MathPow(10, precision));
      } else {
         return (MathFloor(value) / MathPow(10, precision));
      }
   }
   return (MathRound(value) / MathPow(10, precision));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getVolumeScore(int index, int indexMin, int indexMax) {
   long volMin = Volume[indexMin];
   long volMax = Volume[indexMax];
   long vol = Volume[index];
   double RatioVol = (double)(vol - volMin)/(volMax-volMin);
   RatioVol *= (scoreVolumeMax-scoreVolumeMin);
   RatioVol += scoreVolumeMin;

   return RatioVol;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getHighestLowestVolumeIndex(int from, int until,int MODE) {
   long vol = Volume[from];
   int index=from;
   for(int i=from; i<=until; i++) {
      if(MODE == 1 && Volume[i]>=vol) {
         vol = Volume[i];
         index = i;
      } else if(MODE == 0 && Volume[i]<=vol) {
         vol = Volume[i];
         index = i;
      }
   }
   return index;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double getVolumeInsideRange(int indexHigh, int indexLow, int indexCurrent, double rangeMin, double rangeMax) {
//   double volumeCurrent = Volume[indexCurrent];
//   double volumeHigh = Volume[indexHigh];
//   double volumeLowest = Volume[indexLow];
//   double volInRange = NormalizeDouble(rangeMin,4) + NormalizeDouble(((rangeMax - rangeMin)*(volumeCurrent - volumeLowest))/(volumeHigh-volumeLowest),4);
//
//   return volInRange;
//}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PivotType getPivotPointType(int indexOfCandle) {
   double close = Close[indexOfCandle];
   double closeNext = Close[indexOfCandle-1];
   double closePast = Close[indexOfCandle+1];
   double closeNextNext = Close[indexOfCandle+2];
   double closePastPast = Close[indexOfCandle-2];
   double closeNextNextNext = Close[indexOfCandle+3];
   double closePastPastPast = Close[indexOfCandle-3];


   if((closeNext<close && closePast<=close) && (closeNextNext<close && closePastPast<=close)&& (closeNextNextNext<close && closePastPastPast<=close)) {
      return TO_HIGH;
   } else if((close<closeNext && close<=closePast) && (close<closeNextNext && close<=closePastPast)&& (close<closeNextNextNext && close<=closePastPastPast)) {
      return TO_LOW;
   } else {
      return NOTHING;
   }
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
bool VLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="VLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time=0,            // line time
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0) {       // priority for mouse click
//--- if the line time is not set, draw it via the last bar
   if(!time)
      time=TimeCurrent();
//--- reset the error value
   ResetLastError();
   ResetLastError();
//--- create a vertical line
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0)) {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
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
//| Move the vertical line                                           |
//+------------------------------------------------------------------+
bool VLineMove(const long   chart_ID=0,   // chart's ID
               const string name="VLine", // line name
               datetime     time=0) {     // line time
//--- if line time is not set, move the line to the last bar
   if(!time)
      time=TimeCurrent();
//--- reset the error value
   ResetLastError();
//--- move the vertical line
   if(!ObjectMove(chart_ID,name,0,time,0)) {
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
   }
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
//| Delete the vertical line                                         |
//+------------------------------------------------------------------+
bool VLineDelete(const long   chart_ID=0,   // chart's ID
                 const string name="VLine") { // line name
//--- reset the error value
   ResetLastError();
//--- delete the vertical line
   if(!ObjectDelete(chart_ID,name)) {
      Print(__FUNCTION__,
            ": failed to delete the vertical line! Error code = ",GetLastError());
      return(false);
   }
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
