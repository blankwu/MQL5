//+------------------------------------------------------------------+
//|                                                  BollingerEA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| 引用自定义交易类库                                               |
//+------------------------------------------------------------------+
#include <MyClass\shuju.mqh>
ShuJu shuju;
#include <MyClass\交易类\信息类.mqh>
仓位信息 cw;
交易品种信息 pz;
#include <MyClass\交易类\交易指令.mqh>
交易指令 jy;

//+------------------------------------------------------------------+
//| 初始化【BollingerEA】参数（全局变量）                            |
//+------------------------------------------------------------------+

int magic_DL = 666;                 //自定义Bollinger_EA的ID
int deviation = 5;                  //能接受的因网络原因或订单排队时产生的做单误差点位
int sl = 100;                       //止损点位
int tp = 100;                       //止盈点位
double lots = 0.01;                 //默认交易手数
string commBuy = "BUY";
string commSell = "SELL";

int 手续费比例 = 4;
int 开单时点差 = 0;

int OrderNumber_BUY = 0;            //初始化已开仓做多订单的数量
int OrderNumber_SELL = 0;           //初始化已开仓做空订单的数量

//用于控制开单位置（同一条K线只开单一次）
datetime openTime = 0;              //开单时间
datetime openTimeArray[];           //开单时间数组

input int 止损点位 = 20;
//初始化MACD参数
input int KEMA = 12;
input int MEMA = 26;
input int SMA = 9;
//初始化移动平均线参数
input int MA = 20;

//只能以动态数组方式声明，不能以Array[8]这种形式声明，否则ArraySetAsSeries()索引函数设置倒序排列时将失效！
double MACD[];                      //此数组存储上轨数据
double Signal[];                    //此数组存储中轨数据
double _MA[];

double ask = 0.0;                   //当前的做多价
double bid = 0.0;                   //当前的做空价
double closePrice[];

//获取持仓的订单信息
double order_Price = 0.0;           //最近一笔持仓订单的开单价格
double order_Lots = 0.0;            //最近一笔持仓订单的下单手数
double order_SL = 0.0;              //最近一笔持仓订单的止损价格
double order_TP = 0.0;              //最近一笔持仓订单的止盈价格
//获取已结束的历史订单信息
double LS_Lots = 0.0;               //最近一笔历史订单的下单量
double LS_Price = 0.0;              //最近一笔历史订单的盈亏
double LS_SXF = 0.0;                //最近一笔历史订单的手续费
//斐波那契数列
int 计数器 = 0;
double 斐波那契 = 0;
string 客户端全局变量名称;
int 客户端全局变量 = 2;
//+------------------------------------------------------------------+
//| 初始化函数，程序首次运行仅执行一次                               |
//+------------------------------------------------------------------+
int OnInit()
{
   //客户端全局变量名称 = EA名称 + 货币对名称 + Magic自定义编码名称（使客户端全局变量不与其他EA的客户端全局变量混淆）
   客户端全局变量名称 = MQLInfoString(MQL_PROGRAM_NAME) + Symbol() + IntegerToString(magic_DL);
   if(GlobalVariableCheck(客户端全局变量名称 + "计数器") == false)
   {
      GlobalVariableSet(客户端全局变量名称 + "计数器", 客户端全局变量);
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| 程序关闭时执行一次，释放占用内存                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   printf("自动交易程序被关闭！");
   printf("图表窗口被关闭或者EA程序被卸载！");
}
//+------------------------------------------------------------------+
//| 主函数，价格每波动一次执行一次                                   |
//+------------------------------------------------------------------+
void OnTick()
{
   //获取指定时段内K线的开盘时间
   shuju.gettime(openTimeArray, 3);
   //获取指定多少根K线内的MACD数据
   shuju.MACD(MACD, Signal, 3, Symbol(), PERIOD_CURRENT, KEMA, MEMA, SMA, PRICE_CLOSE);
   //获取移动平均线的数据
   shuju.MA(_MA, 3, Symbol(),  PERIOD_CURRENT, MA, 0, MODE_SMA, PRICE_CLOSE);
   //获取当前价格数据
   shuju.getclose(closePrice, 3);

   //获取当前时刻的做多做空价格
   ask = shuju.getask(Symbol());
   bid = shuju.getbid(Symbol());
   //获取已持仓的单数
   OrderNumber_BUY = cw.OrderNumber(Symbol(), 0, magic_DL);
   OrderNumber_SELL = cw.OrderNumber(Symbol(), 1, magic_DL);
   //获取历史订单数据
   ulong orderID = cw.OrderZJLS(Symbol(), LS_Lots, LS_Price, LS_SXF);
   
   if(OrderNumber_BUY == 0 && OrderNumber_SELL == 0) //检查目前是否为空仓
   {
      if(MACD[2] < 0 && MACD[1] > 0 && closePrice[0] > _MA[0]) //做多开单条件
      {
         //控制同一条K线只能开一次单
         if(openTime != openTimeArray[0])
         {  
            //检查历史单是否为0 或者 历史单未亏损
            if(orderID == 0 || LS_Price - LS_SXF > 0)
            { 
               //初始化客户端全局变量——计数器
               Initialize();
               //开单
               if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, lots, sl, tp, commBuy, magic_DL, deviation)>0)
               {
                  开单时点差 = pz.实时点差(Symbol());
                  printf("开单成功！点差：" + IntegerToString(开单时点差) + " 持仓方向：做多");
                  jy.OrderModify(Symbol(), POSITION_TYPE_BUY, _MA[0]-止损点位*Point(), 0, magic_DL);
               }
            }
            //历史订单为亏损
            if(LS_Price - LS_SXF < 0)
            {
               //获取客户端全局变量的值
               计数器 = GetUpdata();
               斐波那契 = Fibonacci(计数器);
               //开单
               if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, 斐波那契 * 0.01, sl, tp, commBuy, magic_DL, deviation)>0)
               {
                  开单时点差 = pz.实时点差(Symbol());
                  printf("开单成功！点差：" + IntegerToString(开单时点差) + " 持仓方向：做多");
                  jy.OrderModify(Symbol(), POSITION_TYPE_BUY, _MA[0]-止损点位*Point(), 0, magic_DL);
               }
            }
            openTime = openTimeArray[0];        
         }
      }
   }
   else
   {
      //获取持仓数据
      cw.OrderZJ(Symbol(), magic_DL, order_Price, order_Lots, order_SL, order_TP);
      
      if(OrderNumber_BUY > 0)
      {
         //如果价格上涨20个点，那么
         if(closePrice[0] - 止损点位 * Point()  >= order_Price)
         {
            if(order_SL != order_Price+(开单时点差+手续费比例)*Point())
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_BUY, order_Price+(开单时点差+手续费比例)*Point(), 0, magic_DL); 
               printf("保本模式已开启！");   
            }
            //平仓触发条件
            if(MACD[1] < MACD[2])
            {
               jy.OrderClose(Symbol(), ORDER_TYPE_BUY, deviation, magic_DL);
            }
         }
      }
   }
}

//生成斐波那契数的函数
int Fibonacci(int n)
{
    if(n<0)
    {
        return 0;
    }

    if(n == 0 || n==1)
    {
        return n;
    }

    int num1 = 0, num2 = 1;
    
    for(int i=2; i<=n; i++){
        num2 = num1+num2;
        num1 = num2-num1;
    }
    
    return num2;
}
//初始化客户端全局变量——计数器
void Initialize()
{
   if(GlobalVariableCheck(客户端全局变量名称 + "计数器") == true)
   {
      GlobalVariableSet(客户端全局变量名称 + "计数器", 客户端全局变量);
   }
}

int GetUpdata()
{
   //获取客户端全局变量的值
   int counter = int(GlobalVariableGet(客户端全局变量名称 + "计数器")) + 1;
   
   //更新客户端全局变量——计数器的值
   if(GlobalVariableCheck(客户端全局变量名称 + "计数器") == true)
   {
      GlobalVariableSet(客户端全局变量名称 + "计数器", counter);
   }
   
   return counter;
}