Create Database Customer
use Customer

create table Customer_View_360
(
Customer_Id Int Primary Key Identity(11,1),
Gender VARCHAR (20),
City_Code VARCHAR (20),
Age_in_month Int,
Basket_Count Int,
Total_Sal_amt Int,
Total_Sal_qty Int,
Unq_cat_cnt Int,
Unq_sCat_cnt Int,
Unq_chnl_cnt Int,
Last_trans_date Date,
Avg_basket_qty Int,
Avg_basket_val Int,
Prod_Cat Varchar(20),
Prod_Sub_cat varchar(20),
Prd_Sub_cat_Code int,
Store_Type varchar(20),
Rate Float
)

Select * from Customer_View_360



