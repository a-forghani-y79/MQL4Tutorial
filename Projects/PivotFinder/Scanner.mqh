
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


class Scanner {
public:
   int from;
   int until;
   int ratio;
   PriceChunk* priceChunkArray[];
   
   void appendPriceChunk(PriceChunk &priceChunk){
   ArrayResize(this.priceChunkArray,ArraySize(this.priceChunkArray)+1);
   this.priceChunkArray[ArraySize(this.priceChunkArray)-1]=priceChunk;
   
   };

};