#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

class JiaoYi
{
   public:
   ulong Buy(string symbol,double Lost,int Deviation,int slpoint,int tppoint,string Com,int Magic);  //开单做多
   ulong Sell(string symbol,double Lost,int Deviation,int slpoint,int tppoint,string Com,int Magic);
   void Modify_SL_TP(string symbol,ENUM_POSITION_TYPE type,double sl,double tp,int Magic);
   void CloseallBuy(string symbol,int Deviation,int Magic);
   void CloseallSell(string symbol,int Deviation,int Magic);
   void Closeall(string symbol,int Deviation,int Magic);
   double FormatLots(string symbol,double Lots);
   int DingDanShu(string symbol,ENUM_POSITION_TYPE type,int Magic);
   void YiDongSL(int yidongdian,string symbol,ENUM_POSITION_TYPE type,int magic);
   ulong ZuiJinDan(string symbol,ENUM_POSITION_TYPE type,double &openprice,long &opentime,double &openlost,double &opensl,double &opentp,int Magic=0);
   ulong ZuiJinLiShiDan(string symbol,ENUM_POSITION_TYPE type,double &ShouXuFei,double &LiRun,double &OpenLost,int &Magic);
   ulong KuiSunDan(string symbol,double &OpenLost,int &Magic);
};

double JiaoYi::FormatLots(string symbol,double Lots)
{
     double a=0;
     double minilots=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
     double steplots=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
     if(Lots<minilots)
     {
         return(0);
     } 
     else
     {
        double b=MathFloor(Lots/minilots)*minilots;
        a=b+MathFloor((Lots-b)/steplots)*steplots;
     }
     return(a); 
}

ulong JiaoYi::Buy(string symbol,double Lost,int Deviation,int slpoint,int tppoint,string Com,int Magic)
{ 
   int NoOrder=0;
   ulong OrderID=0;
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PositionGetInteger(POSITION_MAGIC)==Magic && PositionGetString(POSITION_COMMENT)==Com)
         {
            NoOrder=1;
            return(0);
         }
      }    
   }
   if(NoOrder==0)
      {
         MqlTradeRequest request={0}; 
         MqlTradeResult  result={0};
         request.action=TRADE_ACTION_DEAL;
         request.symbol=symbol;
         request.type=ORDER_TYPE_BUY;
         request.volume=Lost;
         request.deviation=Deviation;
         request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
         request.sl=SymbolInfoDouble(symbol,SYMBOL_ASK)-slpoint*Point();
         request.tp=SymbolInfoDouble(symbol,SYMBOL_ASK)+tppoint*Point();
         request.comment=Com;
         request.magic=Magic;
         
         if(!OrderSend(request,result))
            PrintFormat("做多开单错误 %d",GetLastError());
            PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
            OrderID=result.order;
      }
   return(OrderID);
}

ulong JiaoYi::Sell(string symbol,double Lost,int Deviation,int slpoint,int tppoint,string Com,int Magic)
{ 
   int NoOrder=0;
   ulong OrderID=0;
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PositionGetInteger(POSITION_MAGIC)==Magic && PositionGetString(POSITION_COMMENT)==Com)
         {
            NoOrder=1;
            return(0);
         }
      }    
   }
   if(NoOrder==0)
      {
         MqlTradeRequest request={0}; 
         MqlTradeResult  result={0};
         request.action=TRADE_ACTION_DEAL;
         request.symbol=symbol;
         request.type=ORDER_TYPE_SELL;
         request.volume=Lost;
         request.deviation=Deviation;
         request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
         request.sl=SymbolInfoDouble(symbol,SYMBOL_BID)+slpoint*Point();
         request.tp=SymbolInfoDouble(symbol,SYMBOL_BID)-tppoint*Point();
         request.comment=Com;
         request.magic=Magic;
         
         if(!OrderSend(request,result))
            PrintFormat("做空开单错误 %d",GetLastError());
            PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
            OrderID=result.order;
      }
   return(OrderID);
}

void JiaoYi::CloseallBuy(string symbol,int Deviation,int Magic=0)
{
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
            if(Magic==0)
            {
               MqlTradeRequest request={0}; 
               MqlTradeResult  result={0};
               request.action=TRADE_ACTION_DEAL;
               request.symbol=symbol;
               request.position=PositionGetTicket(i);
               request.type=ORDER_TYPE_SELL;
               request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
               request.volume=PositionGetDouble(POSITION_VOLUME);
               request.deviation=Deviation;
               if(!OrderSend(request,result))
               PrintFormat("平多单错误 %d",GetLastError());
            }
            else
            {
               if(PositionGetInteger(POSITION_MAGIC)==Magic)
               {
                  MqlTradeRequest request={0}; 
                  MqlTradeResult  result={0};
                  request.action=TRADE_ACTION_DEAL;
                  request.symbol=symbol;
                  request.position=PositionGetTicket(i);
                  request.type=ORDER_TYPE_SELL;
                  request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
                  request.volume=PositionGetDouble(POSITION_VOLUME);
                  request.deviation=Deviation;
                  if(!OrderSend(request,result))
                  PrintFormat("平多单错误 %d",GetLastError());
               }
            }
         }
      }
   }
}

void JiaoYi::CloseallSell(string symbol,int Deviation,int Magic=0)
{
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         {
            if(Magic==0)
            {
               MqlTradeRequest request={0}; 
               MqlTradeResult  result={0};
               request.action=TRADE_ACTION_DEAL;
               request.symbol=symbol;
               request.position=PositionGetTicket(i);
               request.type=ORDER_TYPE_BUY;
               request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
               request.volume=PositionGetDouble(POSITION_VOLUME);
               request.deviation=Deviation;
               if(!OrderSend(request,result))
               PrintFormat("平空单错误 %d",GetLastError());
            }
            else
            {
               if(PositionGetInteger(POSITION_MAGIC)==Magic)
               {
                  MqlTradeRequest request={0}; 
                  MqlTradeResult  result={0};
                  request.action=TRADE_ACTION_DEAL;
                  request.symbol=symbol;
                  request.position=PositionGetTicket(i);
                  request.type=ORDER_TYPE_BUY;
                  request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
                  request.volume=PositionGetDouble(POSITION_VOLUME);
                  request.deviation=Deviation;
                  if(!OrderSend(request,result))
                  PrintFormat("平空单错误 %d",GetLastError());
               }
            }
         }
      }
   }
}

void JiaoYi::Closeall(string symbol,int Deviation,int Magic=0)
{
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
            if(Magic==0)
            {
               MqlTradeRequest request={0}; 
               MqlTradeResult  result={0};
               request.action=TRADE_ACTION_DEAL;
               request.symbol=symbol;
               request.position=PositionGetTicket(i);
               request.type=ORDER_TYPE_SELL;
               request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
               request.volume=PositionGetDouble(POSITION_VOLUME);
               request.deviation=Deviation;
               if(!OrderSend(request,result))
               PrintFormat("平多空单错误 %d",GetLastError());
            }
            else
            {
               if(PositionGetInteger(POSITION_MAGIC)==Magic)
               {
                  MqlTradeRequest request={0}; 
                  MqlTradeResult  result={0};
                  request.action=TRADE_ACTION_DEAL;
                  request.symbol=symbol;
                  request.position=PositionGetTicket(i);
                  request.type=ORDER_TYPE_SELL;
                  request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
                  request.volume=PositionGetDouble(POSITION_VOLUME);
                  request.deviation=Deviation;
                  if(!OrderSend(request,result))
                  PrintFormat("平多空单错误 %d",GetLastError());
               }
            }
         }
         if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         {
            if(Magic==0)
            {
               MqlTradeRequest request={0}; 
               MqlTradeResult  result={0};
               request.action=TRADE_ACTION_DEAL;
               request.symbol=symbol;
               request.position=PositionGetTicket(i);
               request.type=ORDER_TYPE_BUY;
               request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
               request.volume=PositionGetDouble(POSITION_VOLUME);
               request.deviation=Deviation;
               if(!OrderSend(request,result))
               PrintFormat("平空多单错误 %d",GetLastError());
            }
            else
            {
               if(PositionGetInteger(POSITION_MAGIC)==Magic)
               {
                  MqlTradeRequest request={0}; 
                  MqlTradeResult  result={0};
                  request.action=TRADE_ACTION_DEAL;
                  request.symbol=symbol;
                  request.position=PositionGetTicket(i);
                  request.type=ORDER_TYPE_BUY;
                  request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
                  request.volume=PositionGetDouble(POSITION_VOLUME);
                  request.deviation=Deviation;
                  if(!OrderSend(request,result))
                  PrintFormat("平空多单错误 %d",GetLastError());
               }
            }
         }
      }
   }
}

void JiaoYi::Modify_SL_TP(string symbol,ENUM_POSITION_TYPE type,double SL,double TP,int Magic=0)
 {
   int t=PositionsTotal();
   for(int i=t-1;i>=0;i--)
     {
       if(PositionGetTicket(i)>0)
        {
          if(PositionGetString(POSITION_SYMBOL)==symbol)
           {
             if(type==POSITION_TYPE_BUY)
              {
                if(Magic==0)
                 {
                     if((NormalizeDouble(SL,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))||NormalizeDouble(TP,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))))
                     {
                       MqlTradeRequest request={0};
                       MqlTradeResult  result={0};
                       request.action=TRADE_ACTION_SLTP;
                       request.position=PositionGetTicket(i);
                       request.symbol=symbol;
                       request.sl=NormalizeDouble(SL,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                       request.tp=NormalizeDouble(TP,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                       if(SL<0) request.sl=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                       if(TP<0) request.tp=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                       if(!OrderSend(request,result))
                       PrintFormat("OrderSend error %d",GetLastError()); 
                      }
                 }
                else
                 {
                    if(PositionGetInteger(POSITION_MAGIC)==Magic)
                    {
                        if((NormalizeDouble(SL,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))||NormalizeDouble(TP,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))))
                         {
                          MqlTradeRequest request={0};
                          MqlTradeResult  result={0};
                          request.action=TRADE_ACTION_SLTP;
                          request.position=PositionGetTicket(i);
                          request.symbol=symbol;
                          request.sl=NormalizeDouble(SL,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                          request.tp=NormalizeDouble(TP,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                          if(SL<0) request.sl=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                          if(TP<0) request.tp=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                          if(!OrderSend(request,result))
                          PrintFormat("OrderSend error %d",GetLastError()); 
                         }
                    }
                 }
              }
              if(type==POSITION_TYPE_SELL)
              {
                 if(Magic==0)
                  {
                     if((NormalizeDouble(SL,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))||NormalizeDouble(TP,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))))
                      {
                       MqlTradeRequest request={0};
                       MqlTradeResult  result={0};
                       request.action=TRADE_ACTION_SLTP;
                       request.position=PositionGetTicket(i);
                       request.symbol=symbol;
                       request.sl=NormalizeDouble(SL,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                       request.tp=NormalizeDouble(TP,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                       if(SL<0) request.sl=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                       if(TP<0) request.tp=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                       if(!OrderSend(request,result))
                       PrintFormat("OrderSend error %d",GetLastError()); 
                      }
                 }
                else
                 {
                    if(PositionGetInteger(POSITION_MAGIC)==Magic)
                    {
                        if((NormalizeDouble(SL,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))||NormalizeDouble(TP,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))))
                         {
                          MqlTradeRequest request={0};
                          MqlTradeResult  result={0};
                          request.action=TRADE_ACTION_SLTP;
                          request.position=PositionGetTicket(i);
                          request.symbol=symbol;
                          request.sl=NormalizeDouble(SL,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                          request.tp=NormalizeDouble(TP,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                          if(SL<0) request.sl=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                          if(TP<0) request.tp=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
                          if(!OrderSend(request,result))
                          PrintFormat("######修改止损止盈错误代码： %d",GetLastError()); 
                         }
                    }
                 }
              }
           } 
        }
     }
 }

ulong JiaoYi::ZuiJinDan(string symbol,ENUM_POSITION_TYPE type,double &Openprice,long &Opentime,double &Openlost,double &Opensl,double &Opentp,int Magic=0)
{
   Openprice=0;
   Opentime=0;
   Openlost=0;
   Opensl=0;
   Opentp=0;
   ulong ticket=0;
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_TYPE)==type)
         {
            if(Magic==0)
            {
               Openprice=PositionGetDouble(POSITION_PRICE_OPEN);
               Opentime=PositionGetInteger(POSITION_TIME);
               Openlost=PositionGetDouble(POSITION_VOLUME);
               Opensl=PositionGetDouble(POSITION_SL);
               Opentp=PositionGetDouble(POSITION_TP);
               ticket=PositionGetInteger(POSITION_TICKET);
               break;
            }
            else
            {
               if(PositionGetInteger(POSITION_MAGIC)==Magic)
               {
                  Openprice=PositionGetDouble(POSITION_PRICE_OPEN);
                  Opentime=PositionGetInteger(POSITION_TIME);
                  Openlost=PositionGetDouble(POSITION_VOLUME);
                  Opensl=PositionGetDouble(POSITION_SL);
                  Opentp=PositionGetDouble(POSITION_TP);
                  ticket=PositionGetInteger(POSITION_TICKET);
                  break; 
               }
            }
         }
      }
   }
   return(ticket);      
}

ulong JiaoYi::ZuiJinLiShiDan(string symbol,ENUM_POSITION_TYPE type,double &ShouXuFei,double &LiRun,double &OpenLost,int &Magic)
{
   ShouXuFei=0;
   LiRun=0;
   OpenLost=0;
   ulong ticket=0;
   HistorySelect(0,TimeCurrent());
   int saomiao=HistoryDealsTotal();
   
   for(int i=saomiao-1;i>=0;i--)
   {
      if((ticket=HistoryDealGetTicket(i))>0)
      {
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)==symbol && HistoryDealGetInteger(ticket,DEAL_TYPE)==type && HistoryDealGetInteger(ticket,DEAL_MAGIC)==Magic)
         {
               ShouXuFei=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
               LiRun=HistoryDealGetDouble(ticket,DEAL_PROFIT);
               OpenLost=HistoryDealGetDouble(ticket,DEAL_VOLUME);
               break;
         }
      }
   }
   return(ticket);      
}

ulong JiaoYi::KuiSunDan(string symbol,double &OpenLost,int &Magic)
{
   ENUM_POSITION_TYPE Buytype=POSITION_TYPE_BUY;
   ENUM_POSITION_TYPE Selltype=POSITION_TYPE_SELL;
   double ShouXuFei=0;
   double LiRun=0;
   OpenLost=0;
   ulong ticket=0;
   HistorySelect(0,TimeCurrent());
   int saomiao=HistoryDealsTotal();
   
   for(int i=saomiao-1;i>=saomiao-2;i--)
   {
      if((ticket=HistoryDealGetTicket(i))>0)
      {
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)==symbol && HistoryDealGetInteger(ticket,DEAL_TYPE)==Buytype && HistoryDealGetInteger(ticket,DEAL_MAGIC)==Magic)
         {
               ShouXuFei=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
               LiRun=HistoryDealGetDouble(ticket,DEAL_PROFIT);
               OpenLost=HistoryDealGetDouble(ticket,DEAL_VOLUME);
               if(LiRun-ShouXuFei<0)
               {
                  return(ticket); 
               }
               else   
               {
                  ticket=0;      
               }
         }
         else
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)==symbol && HistoryDealGetInteger(ticket,DEAL_TYPE)==Selltype && HistoryDealGetInteger(ticket,DEAL_MAGIC)==Magic)
         {
               ShouXuFei=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
               LiRun=HistoryDealGetDouble(ticket,DEAL_PROFIT);
               OpenLost=HistoryDealGetDouble(ticket,DEAL_VOLUME);
               if(LiRun-ShouXuFei<0)
               {
                  return(ticket); 
               }
               else   
               {
                  ticket=0;      
               }             
         }
      }
   }
/*
   if(ticket>0)
   {
      return(ticket); 
   }
   else   
   if(ticket==HistoryDealGetTicket(0))
   {
      ticket=0;      
   }*/
   return(ticket);    
}

int JiaoYi::DingDanShu(string symbol,ENUM_POSITION_TYPE Type,int Magic=0)
{
   int a=0;
   int t=PositionsTotal();
   for(int i=t-1;i>=0;i--)
   {
    if(PositionGetTicket(i)>0)
     {
       if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_TYPE)==Type)
       {
          if(Magic==0)
          {
             a++;
          }
          else
          {
             if(PositionGetInteger(POSITION_MAGIC)==Magic)
             {
                a++;
             }
          }
       }
     }
   }
  return(a);
}

void JiaoYi::YiDongSL(int yidongdian,string symbol,ENUM_POSITION_TYPE type,int Magic)
 {
   int t=PositionsTotal();
   for(int i=t-1;i>=0;i--)
     {
       if(PositionGetTicket(i)>0)
        {
          if(PositionGetString(POSITION_SYMBOL)==symbol)
           {
             double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
             double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
             double dig=StringToDouble(IntegerToString(SymbolInfoInteger(symbol,SYMBOL_DIGITS)));
             double pot=SymbolInfoDouble(symbol,SYMBOL_POINT);
             double op=PositionGetDouble(POSITION_PRICE_OPEN);
             double SL=PositionGetDouble(POSITION_SL);
             double TP=PositionGetDouble(POSITION_TP);  
             if(type==POSITION_TYPE_BUY)
              {
                if((bid-op)>=pot*yidongdian && (SL<(bid-pot*yidongdian) || (SL==0)))
                 {
                   if(Magic==0)
                    {
                       MqlTradeRequest request={0};
                       MqlTradeResult  result={0};
                       request.action=TRADE_ACTION_SLTP;
                       request.position=PositionGetTicket(i);
                       request.symbol=symbol;
                       request.sl=bid-pot*yidongdian;
                       request.tp=TP;
                       if(!OrderSend(request,result))
                       PrintFormat("OrderSend error %d",GetLastError()); 
                    }
                   else
                    {
                       if(PositionGetInteger(POSITION_MAGIC)==Magic)
                       {
                          MqlTradeRequest request={0};
                          MqlTradeResult  result={0};
                          request.action=TRADE_ACTION_SLTP;
                          request.position=PositionGetTicket(i);
                          request.symbol=symbol;
                          request.sl=bid-pot*yidongdian;
                          request.tp=TP;
                          if(!OrderSend(request,result))
                          PrintFormat("OrderSend error %d",GetLastError()); 
                       }
                    } 
                 }
              }
              if(type==POSITION_TYPE_SELL)
              {
                 if((op-ask)>=pot*yidongdian && ((SL>(ask+pot*yidongdian)) || (SL==0)))
                  {
                    if(Magic==0)
                     {
                       MqlTradeRequest request={0};
                       MqlTradeResult  result={0};
                       request.action=TRADE_ACTION_SLTP;
                       request.position=PositionGetTicket(i);
                       request.symbol=symbol;
                       request.sl=ask+pot*yidongdian;
                       request.tp=TP;
                       if(!OrderSend(request,result))
                       PrintFormat("OrderSend error %d",GetLastError()); 
                    }
                    else
                    {
                       if(PositionGetInteger(POSITION_MAGIC)==Magic)
                       {
                          MqlTradeRequest request={0};
                          MqlTradeResult  result={0};
                          request.action=TRADE_ACTION_SLTP;
                          request.position=PositionGetTicket(i);
                          request.symbol=symbol;
                          request.sl=ask+pot*yidongdian;
                          request.tp=TP;
                          if(!OrderSend(request,result))
                          PrintFormat("OrderSend error %d",GetLastError()); 
                       }
                    }
                  }
              }
           } 
        }
     }
 }   