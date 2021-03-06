//+------------------------------------------------------------------+
//|                                                       新建EA模板 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "新建EA模板"
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| 引入程序需要的类库并创建对象                                     |
//+------------------------------------------------------------------+
#include <MyClass\shuju.mqh>
#include <MyClass\交易类\信息类.mqh>
#include <MyClass\交易类\交易指令.mqh>

ShuJu shuju;
账户信息 zh;
仓位信息 cw;
交易指令 jy;

//+------------------------------------------------------------------+
//| 初始化全局变量                                                   |
//+------------------------------------------------------------------+

//经过半年测试 快15 慢27 利润最大 34.76元
input int kma = 2;
input int mma = 8;

double lots = 0.01;
int sl = 50;
int tp = 50;
int magic = 123;
int deviation = 5;

double KMA[];
double MMA[];

datetime 开盘时间 = 0;
datetime openTime[];

//+------------------------------------------------------------------+
//| 初始化函数，程序首次运行仅执行一次                               |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 主函数，价格每波动一次执行一次                                   |
//+------------------------------------------------------------------+
void OnTick()
{
   shuju.gettime(openTime, 1); 
   shuju.MA(KMA, 3, Symbol(), PERIOD_CURRENT, kma, 0, MODE_SMA, PRICE_CLOSE);
   shuju.MA(MMA, 3, Symbol(), PERIOD_CURRENT, mma, 0, MODE_SMA, PRICE_CLOSE); 
   /*
   if(开盘时间 != openTime[0])
   {
      printf("k1 = " + KMA[1]);
      printf("m1 = " + MMA[1]);
      printf("k2 = " + KMA[2]);     
      printf("m2 = " + MMA[2]);
      
      开盘时间 = openTime[0];
   }
   */
   int numBuy  = cw.OrderNumber(Symbol(), 0, magic);
   int numSell = cw.OrderNumber(Symbol(), 1, magic);
   
   if(KMA[2] < MMA[2] && KMA[1] > MMA[1])
   {
      if(开盘时间 != openTime[0])
      {
         if(numBuy == 0)
         {
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, lots, sl, tp, "BUY", magic, deviation) > 0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_BUY, 0, 0, magic);
            }
         }
         if(numSell > 0)
         {
            jy.OrderClose(Symbol(), ORDER_TYPE_SELL, deviation, magic);
         }
         开盘时间 = openTime[0];
      }
   }
   
   if(KMA[2] > MMA[2] && KMA[1] < MMA[1])
   {
      if(开盘时间 != openTime[0])
      {
         if(numSell == 0)
         {
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, lots, sl, tp, "SELL", magic, deviation) > 0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_SELL, 0, 0, magic);
            }
         }
         if(numBuy > 0)
         {
            jy.OrderClose(Symbol(), ORDER_TYPE_BUY, deviation, magic);
         }
         开盘时间 = openTime[0];
      }
   }
}

//+------------------------------------------------------------------+
//| 程序关闭时执行一次，释放占用内存                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   printf("智能交易程序已关闭！");
   printf("图表窗口被关闭或者智能程序被卸载！");
}

//=========================== 程序的最后一行==========================

