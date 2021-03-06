#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <MyClass\shuju.mqh>
ShuJu shuju;
#include <MyClass\交易类\交易指令.mqh>
交易指令 jy;
#include <MyClass\交易类\信息类.mqh>
仓位信息 cw;
#include <MyClass\交易类\仓位管理.mqh>
仓位管理 hg;

int deviation = 5;
int magic_HG = 888;
string commBuy = "Buy_Stoch";
string commSell = "Sell_Stoch";
int 追单次数 = 4;

input int ATR震荡周期 = 20;
input int 开仓上通道 = 20;     //前多少根K线的最高价
input int 开仓下通道 = 20;     //前多少根K线的最低价
input int 平仓上通道 = 10;     //前多少根K线的最高价
input int 平仓下通道 = 10;     //前多少根K线的最低价

double openhigh[];
double openlow[];
double closehigh[];
double closelow[];

double ATR[];
double close[];
double openLots = 0.0;
double openPrice = 0.0;
double openSXF = 0.0; 

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{
   shuju.gethigh(openhigh, 开仓上通道);
   shuju.getlow(openlow, 开仓下通道);
   shuju.gethigh(closehigh, 平仓上通道);
   shuju.getlow(closelow, 平仓上通道);
   shuju.ATR(ATR, 1, Symbol(), PERIOD_CURRENT, ATR震荡周期);
 
   double openBuy = openhigh[ArrayMaximum(openhigh, 1)];
   double openSell = openlow[ArrayMinimum(openlow, 1)];
   double closeBuy = closelow[ArrayMinimum(closelow, 1)];
   double closeSell = closehigh[ArrayMaximum(closehigh, 1)];
   
   double buyNumber = cw.OrderNumber(Symbol(), 0, magic_HG);
   double sellNumber = cw.OrderNumber(Symbol(), 1, magic_HG);
 
   double N = ATR[0];
   double lots = hg.HG_LOTS1(Symbol(), N);
   double buy_SL = hg.HG_SL(Symbol(), N, ORDER_TYPE_BUY);
   double sell_SL = hg.HG_SL(Symbol(), N, ORDER_TYPE_SELL);
   
   shuju.getclose(close, 2);
   cw.OrderZJ(Symbol(), magic_HG, openPrice, openLots);
   /*
   printf("N " + N);
   printf("lots " + lots);
   printf("buy_SL " + buy_SL);
   printf("sell_SL " + sell_SL);
   printf("buyNumber " + buyNumber);
   printf("sellNumber " + sellNumber);
   printf("openBuy " + openBuy);
   printf("openSell " + openSell);
   printf("closeBuy " + closeBuy);
   printf("closeSell " + closeSell);
   printf("close " + close[0]);
*/
   if(close[0] > openBuy && buyNumber == 0)
   {
      if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, lots, 1000, 1000, commBuy, magic_HG, deviation)>0)
      {
         jy.OrderModify(Symbol(), POSITION_TYPE_BUY, buy_SL, 0, magic_HG);
      }
   }
   if(close[0] < openSell && sellNumber == 0)
   {
      if(jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, lots, 1000, 1000, commSell, magic_HG, deviation)>0)
      {
         jy.OrderModify(Symbol(), POSITION_TYPE_SELL, sell_SL, 0, magic_HG);
      }
   }
   
   if(buyNumber > 0)
   {
      //平仓
      if(close[0]<closeBuy)
      {
         jy.OrderClose(Symbol(), ORDER_TYPE_BUY, deviation, magic_HG);
      }
      //追单
      if(close[0] > openPrice + N * 0.5 && buyNumber < 追单次数)
      {
         if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, openLots, 1000, 1000, string(buyNumber)+"_"+commBuy, magic_HG, deviation)>0)
         {
            jy.OrderModify(Symbol(), POSITION_TYPE_BUY, buy_SL, 0, magic_HG);
         }
      }
   }
   
   if(sellNumber > 0)
   {
      if(close[0]>closeSell)
      {
         jy.OrderClose(Symbol(), ORDER_TYPE_SELL, deviation, magic_HG);
      }
      
      if(close[0] < openPrice - N * 0.5 && sellNumber < 追单次数)
      {
         if(jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, openLots, 1000, 1000, string(sellNumber)+"_"+commSell, magic_HG, deviation)>0)
         {
            jy.OrderModify(Symbol(), POSITION_TYPE_SELL, sell_SL, 0, magic_HG);
         }
      }
   }
}