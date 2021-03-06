#property copyright "存储历史数据，用于LSTM网络训练"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs //使脚本可以提供用户输入界面

//+------------------------------------------------------------------+
//| 初始化全局变量                                                   |
//+------------------------------------------------------------------+
input string 交易品种名称 = "EURUSD";
input ENUM_TIMEFRAMES 图表周期 = PERIOD_H1;
input datetime inputTime = D'2004.01.01 00:00';


string FileName = "EURUSD_Raw_Data.csv";
int totle_k = iBarShift(交易品种名称, 图表周期, inputTime);

datetime openTime[];
double highPrice[];
double openPrice[];
double lowPrice[];
double closePrice[];

long tickVolume[];

//+------------------------------------------------------------------+
//| 脚本程序启动函数,仅执行一次                                      |
//+------------------------------------------------------------------+
void OnStart()
{
   printf("蜡烛图总数：" + string(totle_k));
   //调用SaveData函数,把数据写入文件
   SaveData();
}

//+------------------------------------------------------------------+
//| 保存数据函数，把数据写入文件                                     |
//+------------------------------------------------------------------+
void SaveData()
{
   //获取蜡烛图的高开低收价格
   CopyTime (交易品种名称, 图表周期, 0, totle_k, openTime);
   CopyHigh (交易品种名称, 图表周期, 0, totle_k, highPrice);
   CopyOpen (交易品种名称, 图表周期, 0, totle_k, openPrice);
   CopyLow  (交易品种名称, 图表周期, 0, totle_k, lowPrice);
   CopyClose(交易品种名称, 图表周期, 0, totle_k, closePrice);
   CopyTickVolume(交易品种名称,图表周期, 0, totle_k, tickVolume);
   
   //以读写方式打开文件(如果没有此文件将创建此文件)
   int SaveData = FileOpen(FileName, FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_TXT|FILE_ANSI, ",", CP_UTF8);
   //判断文件是否正确打开
   if(SaveData != INVALID_HANDLE)
   {
      int i = 0;
      for(i=0; i<totle_k-1; i++)
      {       
         //把数据写入文件
         FileWrite(SaveData, openTime[i], highPrice[i], openPrice[i], lowPrice[i], closePrice[i], tickVolume[i]); 
      } 
      //关闭文件
      FileClose(SaveData);
      //提示保存成功
      printf( "已写入" + string(i) + "条记录！");     
   }
   else
   {
      printf("文件未找到或打开失败！");
   }
}
//+------------------------------------------------------------------+
