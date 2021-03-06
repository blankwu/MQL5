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
ShuJu shuju;


//+------------------------------------------------------------------+
//| 初始化全局变量                                                   |
//+------------------------------------------------------------------+
input int NUMBER_K = 2;    //前后至少几根K线高于或低于高低点

double HIGH_PRICE = 0.0;
double LOW_PRICE = 0.0;
double HIGH_DATA[];        //按指定数量获取K线最高价
double LOW_DATA[];         //按指定数量获取K线最低价

datetime OPEN_TIME = 0;    //开盘时间
datetime openTime[];
datetime TIME_DATA[];

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
   // 获取指定范围内每根K线的最高最低价格
   shuju.gethigh(HIGH_DATA, NUMBER_K*2+2, Symbol(), PERIOD_CURRENT);
   shuju.getlow(LOW_DATA, NUMBER_K*2+2, Symbol(), PERIOD_CURRENT);  
   shuju.gettime(TIME_DATA, NUMBER_K*2+2);
   
   // 获取开盘时间 
   shuju.gettime(openTime, 1);          
   
   // 寻找高低点
   if(OPEN_TIME != openTime[0])
   {
      // 获取指定范围内的最高价格(前后至少NUMBER_K根K线低于这个高点)
      if(ArrayMaximum(HIGH_DATA, 1, NUMBER_K*2+2) == NUMBER_K+1)
      {
         HIGH_PRICE = HIGH_DATA[ArrayMaximum(HIGH_DATA, 1, NUMBER_K*2+2)];
         Arrow("HIGH");
      }
      
      // 获取指定范围内的最低价格(前后至少NUMBER_K根K线高于这个低点)
      if(ArrayMinimum(LOW_DATA, 1, NUMBER_K*2+2) == NUMBER_K+1)
      {
         LOW_PRICE = LOW_DATA[ArrayMinimum(LOW_DATA, 1, NUMBER_K*2+2)];
         Arrow("LOW");
      }
      OPEN_TIME = openTime[0];
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
//| 绘制高点标记                                                     |
//+------------------------------------------------------------------+
void Arrow(string H_L)
{
   shuju.gettime(openTime, 1); //开盘时间
   
   if(H_L == "HIGH" && HIGH_PRICE > 0)
   {
      ObjectCreate(0,"HIGH_" + string(TIME_DATA[NUMBER_K+1]),OBJ_ARROW,0,0,0,0,0);                      //创建一个箭头 
      ObjectSetInteger(0,"HIGH_" + string(TIME_DATA[NUMBER_K+1]),OBJPROP_TIME,TIME_DATA[NUMBER_K+1]);   //设置时间 
      ObjectSetInteger(0,"HIGH_" + string(TIME_DATA[NUMBER_K+1]),OBJPROP_COLOR, clrRed);                //设置箭头颜色
      ObjectSetInteger(0,"HIGH_" + string(TIME_DATA[NUMBER_K+1]),OBJPROP_ARROWCODE,108);                //设置箭头代码    
      ObjectSetDouble(0,"HIGH_" + string(TIME_DATA[NUMBER_K+1]),OBJPROP_PRICE,HIGH_PRICE + 15*Point()); //预定价格 
      ChartRedraw(0);  //绘制箭头
   }
   if(H_L == "LOW" && LOW_PRICE > 0)
   {
      ObjectCreate(0,"LOW_" + string(TIME_DATA[NUMBER_K+1]),OBJ_ARROW,0,0,0,0,0);                        //创建一个箭头 
      ObjectSetInteger(0,"LOW_" + string(TIME_DATA[NUMBER_K+1]),OBJPROP_TIME,TIME_DATA[NUMBER_K+1]);     //设置时间 
      ObjectSetInteger(0,"LOW_" + string(TIME_DATA[NUMBER_K+1]),OBJPROP_COLOR, clrGreenYellow);          //设置箭头颜色
      ObjectSetInteger(0,"LOW_" + string(TIME_DATA[NUMBER_K+1]),OBJPROP_ARROWCODE,108);                  //设置箭头代码    
      ObjectSetDouble(0,"LOW_" + string(TIME_DATA[NUMBER_K+1]),OBJPROP_PRICE,LOW_PRICE - 15*Point());    //预定价格 
      ChartRedraw(0);  //绘制箭头
   }
}

//=========================== 程序的最后一行==========================

