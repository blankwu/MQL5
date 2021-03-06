//+------------------------------------------------------------------+
//|                                                     Count_HL.mq5 |
//|                                                               My |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "My"
#property link      "https://www.mql5.com"
#property version   "1.00"

#property indicator_chart_window // 在主图显示指标
#property indicator_buffers 2    // 在数据窗口显示几个指标值
#property indicator_plots   2    // 在主图中显示几个指标值

//+------------------------------------------------------------------+
//| 引入程序需要的类库并创建对象                                     |
//+------------------------------------------------------------------+
#include <MyClass\shuju.mqh>
ShuJu shuju;

input int NUMBER_K = 2;    //前后至少几根K线高于或低于高低点

#property indicator_label1  "High_Price: "  // 参数名称
#property indicator_type1   DRAW_LINE       // 参数类型(线段、箭头...)
#property indicator_color1  clrIvory          // 参数颜色
#property indicator_style1  STYLE_SOLID     // 参数类型(实线、虚线...)
#property indicator_width1  1               // 参数宽度

#property indicator_label2  "Low_Price: "
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrAqua
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

double HIGH_PRICE[];
double LOW_PRICE[];
double HIGH_DATA[];
double LOW_DATA[];
double PRICE = 0.0;
   
//+------------------------------------------------------------------+
//| 自定义指标初始化函数                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   //指标缓冲区映射
   SetIndexBuffer(0, HIGH_PRICE, INDICATOR_DATA);
   SetIndexBuffer(1, LOW_PRICE,  INDICATOR_DATA);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| 自定义指标迭代函数(价格每波动一次执行一次)                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{  
   
   
   //获取图表中每条K线的最高最低价
   //CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, HIGH_DATA);
   //CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, LOW_DATA);
   
   for(int i=0; i<rates_total; i++)
   {  
      //HIGH_PRICE[i] = high[i];
      LOW_PRICE[i] = 0;
      
      printf(i + "------------" + HIGH_PRICE[i]);

      CopyHigh(Symbol(), PERIOD_CURRENT, rates_total-i, NUMBER_K*2+1, HIGH_DATA);
      ArraySetAsSeries(HIGH_DATA,  true);
      
      for(int j=0; j<ArraySize(HIGH_DATA); j++)
      {
         printf(HIGH_DATA[j]);
      }
      
      if(ArrayMaximum(HIGH_DATA, 0) == NUMBER_K)
      {         
         HIGH_PRICE[i] = HIGH_DATA[ArrayMaximum(HIGH_DATA, 0)];
         PRICE = HIGH_PRICE[i];
      }
      else
      {
         HIGH_PRICE[i] = PRICE;
      }
   }
   
   return(rates_total);
}
//+------------------------------------------------------------------+
