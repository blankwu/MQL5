//+------------------------------------------------------------------+
//| 根据设定的每笔最大损失百分比决定下单量                           |
//| ATR参数决定止盈止损点                                            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| 引入程序需要的类库并创建对象                                     |
//+------------------------------------------------------------------+
#include <MyClass\shuju.mqh>
#include <MyClass\交易类\信息类.mqh>
#include <MyClass\交易类\交易指令.mqh>
#include <MyClass\交易类\仓位管理.mqh>

ShuJu sj;
账户信息 zh;
仓位信息 cw_i;
交易指令 jy;
仓位管理 cw_m;

//+------------------------------------------------------------------+
//| 初始化全局变量                                                   |
//+------------------------------------------------------------------+
input int risk = 2;  // 允许最大损失占总资金的比例
input ENUM_TIMEFRAMES 图表周期 = PERIOD_CURRENT;

double maxLoss = risk * zh.账户余额() * 0.01; // 允许的最大损失所对应的余额价值
double lots = 0.0;
double pip = cw_m.PIP_Value(Symbol());// 一标准手价格波动1pip对应的账户资金价值

datetime 开盘时间 = 0;
datetime openTime[];

double ATR[];
double MACD[];
double SIGNAL[];

int KMA = 12;
int MMA = 26;
int SMA = 9;

int sl = 0;
int tp = 0;

int OrderNumber_BUY = 0;
int OrderNumber_SELL = 0;

int deviation = 2;
int magic_SGJ = 868;


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
   //获取开盘时间
   sj.gettime(openTime, 3);
   //获取当前ATR值
   sj.ATR(ATR, 3, Symbol(), 图表周期, 20);
   //设置止盈止损
   sl = int(ATR[0]  / Point());       // 止损为当前ATR的值
   tp = int(ATR[0]  / Point());   // 止盈为当前ATR的两倍
   
   //获取MACD的值
   sj.MACD(MACD, SIGNAL, 5, Symbol(), 图表周期, KMA, MMA, SMA, PRICE_CLOSE);

   if(sl == 0 && tp == 0)
   {
      sl = 50;
      tp = 50;
   }

   //头寸大小 = 所冒风险的金额 /（止损点位 * 每点价值）
   lots = NormalizeDouble(maxLoss / (sl * pip), 2);
   
   //获取持仓数据
   OrderNumber_BUY  = cw_i.OrderNumber(Symbol(), 0, magic_SGJ);
   OrderNumber_SELL = cw_i.OrderNumber(Symbol(), 1, magic_SGJ);
   
   // 开仓条件
   if(开盘时间 != openTime[0])
   { 
      if(ATR[0] > 50 * Point())
      {
         //做多
         if(MACD[3] < 0 && MACD[3] > MACD[2] && MACD[2] < MACD[1])
         {
            jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, lots, sl, tp, "BUY_SGJ", magic_SGJ, deviation);
         }
         //做空   
         if(MACD[3] > 0 && MACD[3] < MACD[2] && MACD[2] > MACD[1])
         {
            jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, lots, sl, tp, "SELL_SGJ", magic_SGJ, deviation);
         }
      }
      开盘时间 = openTime[0]; 
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
//+------------------------------------------------------------------+
