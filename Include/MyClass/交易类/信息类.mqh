#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
/*
本类包含:(账户信息、市场信息、仓位信息、交易品种信息)
*/

class 交易品种信息
{
   public:
   int 实时点差(const string 交易品种);
   double 最小浮动点位(const string 交易品种);
   double 标准手合约数量(const string 交易品种);
   string 基础货币(const string 交易品种);
   string 计价货币(const string 交易品种);
   double YuFuKuan(const string 交易品种, const double 下单量);
};

//有关交易账户的信息
class 账户信息
{
   public:
   
   double 预付款(void);
   double 账户余额(void);
   double 持仓盈亏(void);
   double 当前净值(void);
   double 可用预付款(void);
   double 保证金比例(void);
   double 保证金强平比例(void);  
   double 可用保证金比例(void); 
   
   long 杠杆比例(void);
   
   string 交易账户货币();
};

//有关外汇市场的信息
class 市场信息
{
   public:
   
   市场信息(){}
   ~市场信息(){}
   
   double Ask();
   double Ask(string symbol);
   double Bid();
   double Bid(string symbol);
};

//有关仓位信息和历史订单的信息
class 仓位信息
{
   public:
   int OrderNumber(const string 交易品种, const ENUM_ORDER_TYPE BUY【0】Sell【1】, const int 自定义编号); 
   
   ulong OrderZJ(string 交易品种, int 自定义编号, double &orderPrice);
   ulong OrderZJ(string 交易品种, int 自定义编号, double &orderPrice, double &orderLots, double &orderSL, double &orderTP);
   ulong OrderZJ(string 交易品种, ENUM_POSITION_TYPE type, int 自定义编号, double &OpenPrice, double &OpenLots);
   ulong OrderZJ(string 交易品种, ENUM_POSITION_TYPE type, int 自定义编号, double &OpenPrice, double &OpenLots, double &OpenSL, double &OpenTP);
   
   ulong OrderZJLS(string 交易品种, double &OpenLost, double &LiRun, double &ShouXuFei);
};

//----------------------------交易品种信息----------------------------

int 交易品种信息::实时点差(const string 交易品种)
{
   return int(SymbolInfoInteger(交易品种, SYMBOL_SPREAD));
}

double 交易品种信息::最小浮动点位(const string 交易品种)
{
   return SymbolInfoDouble(交易品种, SYMBOL_TRADE_TICK_SIZE);
} 

double 交易品种信息::标准手合约数量(const string 交易品种)
{
   return SymbolInfoDouble(交易品种, SYMBOL_TRADE_CONTRACT_SIZE);
} 

string 交易品种信息::基础货币(const string 交易品种)
{
   return SymbolInfoString(交易品种, SYMBOL_CURRENCY_BASE);
} 

string 交易品种信息::计价货币(const string 交易品种)
{
   return SymbolInfoString(交易品种, SYMBOL_CURRENCY_PROFIT);
} 

double 交易品种信息::YuFuKuan(const string 交易品种, const double 下单量 = 1.0)
{
   double 预付款 = 0.0;
   string 基础货币 = SymbolInfoString(交易品种, SYMBOL_CURRENCY_BASE);
   string 计价货币 = SymbolInfoString(交易品种, SYMBOL_CURRENCY_PROFIT);
   string 账户货币 = AccountInfoString(ACCOUNT_CURRENCY);
   
   long 杠杆 = AccountInfoInteger(ACCOUNT_LEVERAGE);
   double 市价 = SymbolInfoDouble(交易品种, SYMBOL_BID);
   double 合约大小 = SymbolInfoDouble(交易品种, SYMBOL_TRADE_CONTRACT_SIZE); 
   
   //直盘货币对 如：EURUSD
   if(计价货币 == 账户货币)
   {
      
      预付款 = 合约大小 * 下单量 * 市价 / 杠杆;
   }
   
   //非直盘货币对 如：USDJPY
   if(基础货币 == 账户货币)
   {
      预付款 = 合约大小 * 下单量 / 杠杆;
   }
   
   //交叉盘货币对 如：EURGBP
   if(基础货币 != 账户货币 && 计价货币 != 账户货币)
   {
      市价 = SymbolInfoDouble(基础货币 + 账户货币, SYMBOL_BID);
      预付款 = 合约大小 * 下单量 * 市价 / 杠杆;
   }
   
   return 预付款;
}
//------------------------------账户信息------------------------------
double 账户信息::账户余额(void)
{
   return AccountInfoDouble(ACCOUNT_BALANCE);
}

long 账户信息::杠杆比例(void)
{
   return AccountInfoInteger(ACCOUNT_LEVERAGE);
}

double 账户信息::持仓盈亏(void)
{
   return AccountInfoDouble(ACCOUNT_PROFIT);
}

double 账户信息::当前净值(void)
{
   return AccountInfoDouble(ACCOUNT_EQUITY);
}

double 账户信息::预付款(void)
{
   return AccountInfoDouble(ACCOUNT_MARGIN);
}

double 账户信息::可用预付款(void)
{
   return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
}

double 账户信息::保证金比例(void)
{
   return NormalizeDouble(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2);
}

double 账户信息::可用保证金比例(void)
{
   return AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
}

double 账户信息::保证金强平比例(void)
{
   return AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
}

string 账户信息::交易账户货币()
{
   return AccountInfoString(ACCOUNT_CURRENCY);
}

//------------------------------市场信息------------------------------

double 市场信息::Ask(void)
{
   return(SymbolInfoDouble(Symbol(), SYMBOL_ASK));
}
double 市场信息::Ask(string symbol)
{
   return(SymbolInfoDouble(symbol, SYMBOL_ASK));
}

double 市场信息::Bid(void)
{
   return(SymbolInfoDouble(Symbol(), SYMBOL_BID));
}
double 市场信息::Bid(string symbol)
{
   return(SymbolInfoDouble(symbol, SYMBOL_BID));
}


//------------------------------仓位信息------------------------------

//已开仓订单数量
int 仓位信息::OrderNumber(const string 交易品种, const ENUM_ORDER_TYPE BUY【0】Sell【1】, const int 自定义编号 = 0)
{
   int orderNumber = 0;
   int t = PositionsTotal();
   
   for(int i = t-1; i >= 0; i--)
   {
    if(PositionGetTicket(i) > 0)
     {
       if(PositionGetString(POSITION_SYMBOL)==交易品种 && PositionGetInteger(POSITION_TYPE)==BUY【0】Sell【1】)
       {
          if(自定义编号==0)
          {
             orderNumber++;
          }
          else
          {
             if(PositionGetInteger(POSITION_MAGIC)==自定义编号)
             {
                orderNumber++;
             }
          }
       }
     }
   }
  return(orderNumber);
}

//最近开仓的订单
ulong 仓位信息::OrderZJ(string 交易品种, int 自定义编号, double &orderPrice)
{
   orderPrice = 0.0;
   
   ulong ticket = 0;
   
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==交易品种  && PositionGetInteger(POSITION_MAGIC)==自定义编号)
         {      
            orderPrice=PositionGetDouble(POSITION_PRICE_OPEN);
            ticket=PositionGetInteger(POSITION_TICKET);
            break; 
         }
      }
   }
   return(ticket);      
}
ulong 仓位信息::OrderZJ(string 交易品种, int 自定义编号, double &orderPrice, double &orderLots, double &orderSL, double &orderTP)
{
   orderPrice = 0.0;
   orderLots = 0.0;
   orderSL = 0.0;
   orderTP = 0.0;
   
   ulong ticket = 0;
   
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==交易品种  && PositionGetInteger(POSITION_MAGIC)==自定义编号)
         {      
            orderPrice=PositionGetDouble(POSITION_PRICE_OPEN);
            orderLots=PositionGetDouble(POSITION_VOLUME);
            orderSL=PositionGetDouble(POSITION_SL);
            orderTP=PositionGetDouble(POSITION_TP);
            ticket=PositionGetInteger(POSITION_TICKET);
            break; 
         }
      }
   }
   return(ticket);      
}
//最近开仓的订单(函数重载，按开单类型查找最近已开仓的订单)
ulong 仓位信息::OrderZJ(string 交易品种, ENUM_POSITION_TYPE type, int 自定义编号, double &OpenPrice, double &OpenLots)
{
   OpenPrice = 0.0;
   OpenLots = 0.0;
   
   ulong ticket = 0;
   
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==交易品种 && PositionGetInteger(POSITION_TYPE)==type && PositionGetInteger(POSITION_MAGIC)==自定义编号)
         {      
            OpenPrice=PositionGetDouble(POSITION_PRICE_OPEN);
            OpenLots=PositionGetDouble(POSITION_VOLUME);
            ticket=PositionGetInteger(POSITION_TICKET);
            break; 
         }
      }
   }
   return(ticket);      
}

//最近开仓的订单(函数重载，按开单类型查找最近已开仓的订单)
ulong 仓位信息::OrderZJ(string 交易品种, ENUM_POSITION_TYPE type, int 自定义编号, double &OpenPrice, double &OpenLots, double &OpenSL, double &OpenTP)
{
   OpenPrice = 0.0;
   OpenLots = 0.0;
   OpenSL = 0.0;
   
   ulong ticket = 0;
   
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==交易品种 && PositionGetInteger(POSITION_TYPE)==type && PositionGetInteger(POSITION_MAGIC)==自定义编号)
         {      
            OpenPrice=PositionGetDouble(POSITION_PRICE_OPEN);
            OpenLots=PositionGetDouble(POSITION_VOLUME);
            OpenSL=PositionGetDouble(POSITION_SL);
            OpenTP=PositionGetDouble(POSITION_TP);
            ticket=PositionGetInteger(POSITION_TICKET);
            break; 
         }
      }
   }
   return(ticket);      
}

//已经平仓的历史最近订单(暂时不能按magic查找)
ulong 仓位信息::OrderZJLS(string 交易品种, double &OpenLost, double &LiRun, double &ShouXuFei)
{
   ulong ticket = 0;
   ulong Order_ID = 0;
   
   OpenLost = 0.0;
   LiRun = 0.0;
   ShouXuFei = 0.0;  
   
   //检索指定时间范围内的历史交易记录
   HistorySelect(0,TimeCurrent());
   //历史订单总数
   int saomiao=HistoryDealsTotal();
   
   //查找最近一笔历史交易记录
   for(int i=saomiao-1;i>=0;i--)
   {
      //获取第i个历史记录的处理编号
      ticket=HistoryDealGetTicket(i);
      
      if(ticket>0)
      {
         if(HistoryDealGetString(ticket, DEAL_SYMBOL)==交易品种)
         {
            //获取订单号码
            Order_ID = HistoryDealGetInteger(ticket,DEAL_ORDER);
            //获取下单量
            OpenLost=HistoryDealGetDouble(ticket,DEAL_VOLUME);
            //获取手续费
            ShouXuFei=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
            //获取损益
            LiRun=HistoryDealGetDouble(ticket,DEAL_PROFIT);
            //跳出循环
            break;
         }
      }
   }
   return(Order_ID);      
}