#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <MyClass\shuju.mqh>
ShuJu shuju;
#include <MyClass\交易类\信息类.mqh>
仓位信息 cw;
账户信息 zh;
#include <MyClass\交易类\交易指令.mqh>
交易指令 jy;


double lots = 0.01;
int sl = 1000;
int tp = 1000;
int deviation = 5;
int magic_MD = 888;
string commBuy = "BUY";
string commSell = "SELL";

datetime 开盘时间 = 0;
datetime openTime[];

input int kma = 8;
double KMA[];
input int mma = 10;
double MMA[];

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
   shuju.gettime(openTime, 4);

   shuju.MA(KMA, 3, Symbol(), PERIOD_CURRENT, kma, 0, MODE_EMA, PRICE_CLOSE);  
   shuju.MA(MMA, 3, Symbol(), PERIOD_CURRENT, mma, 0, MODE_EMA, PRICE_CLOSE);  
   
   int OrderNumber_BUY = cw.OrderNumber(Symbol(), 0, magic_MD);
   int OrderNumber_SELL = cw.OrderNumber(Symbol(), 1, magic_MD);
   
   int a = int(MathMod(zh.账户余额(), 200));
   
   ulong orderID = cw.OrderZJLS(Symbol(), openLots, openPrice, openSXF);
   
   

   if(OrderNumber_BUY == 0 && OrderNumber_SELL == 0)
   {  
      //做多条件(EMA金叉)  
      if(KMA[2] < MMA[2] && KMA[1] > MMA[1])
      {
         //开单
         if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, lots, sl, tp, commBuy, magic_MD, deviation)>0)
         {
            jy.OrderModify(Symbol(), POSITION_TYPE_BUY, 0, 0, magic_MD);
            printf(a);
         }           
      }
      //做空条件(EMA死叉)
      if(KMA[2] > MMA[2] && KMA[1] < MMA[1])
      {
         //开单
         if(jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, lots, sl, tp, commSell, magic_MD, deviation)>0)
         {
            jy.OrderModify(Symbol(), POSITION_TYPE_SELL, 0, 0, magic_MD);
            printf(a);
         }
         
      }  
   }  
   
   //平仓
   if(开盘时间 != openTime[0])
   {  
      if(OrderNumber_BUY > 0 || OrderNumber_SELL > 0)
      {
         if(KMA[0] < MMA[0])
         {
            jy.OrderClose(Symbol(), ORDER_TYPE_BUY, deviation, magic_MD);
            printf(a);
         }
         if(KMA[0] > MMA[0])
         {
            jy.OrderClose(Symbol(), ORDER_TYPE_SELL, deviation, magic_MD);
            printf(a);
         }
      }
      
      开盘时间 = openTime[0];
   }

}
