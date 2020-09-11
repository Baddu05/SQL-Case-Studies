Use db_SQLCaseStudies;

/* 1. list all the states in which we have customers who have bought cellphones from 2005 till today?*/

Select State from DIM_LOCATION
Inner Join FACT_TRANSACTIONS
On DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
Inner Join DIM_DATE
On FACT_TRANSACTIONS.Date = DIM_DATE.DATE
Where Year Between '2005' And GETDATE();

/* 2. What state in the US buying more Samsung cellphones */

Select L.State, L.country, M.Manufacturer_Name, sum(F.quantity) as Quantity from FACT_TRANSACTIONS F INNER join DIM_LOCATION L on
f.IDLocation = L.IDLocation and l.Country='US' INNER join DIM_MODEL Mo on  F.IDModel=Mo.IDModel 
INNER join DIM_MANUFACTURER M on M.IDManufacturer=Mo.IDManufacturer
group by L.STATE, L.Country, M.Manufacturer_Name
having m.Manufacturer_Name='Samsung'

/*3. Show the number of transactions for each model per zip code per state? */

Select Mo.Model_Name, l.State, l.Zipcode, Sum(quantity) as Trans from FACT_TRANSACTIONS f inner join DIM_Location L 
on f.IdLocation = l.Idlocation Inner join Dim_Model Mo on F.IDModel = Mo.IDModel
group by Mo.Model_Name, l.State, l.Zipcode
order by Trans desc


/* 4. Show the cheapest cellphone */

select  Model_Name, Unit_Price as Price from DIM_MODEL
where Unit_price = (select min(Unit_price) from DIM_MODEL)


/* 5. Find out the average price of each model in the top5 manufacturers in terms of sales quantity and order by average price.*/


Select Top 5 Ma.Manufacturer_Name, AVG(Mo.Unit_price) as Price, Mo.Model_Name, f.Quantity from DIM_MODEL Mo 
inner join FACT_TRANSACTIONS f on f.IdModel = Mo.IdModel inner join DIM_MANUFACTURER Ma on Ma.IdManufacturer = Mo.IdManufacturer
group by Model_Name, Manufacturer_Name, f.Quantity
order by Avg(Mo.Unit_price) desc

/* 6. List name of the customers and the average amount spent in 2009, where the average is higher than 500.*/

select c.Customer_Name, d.YEAR, AVG(TotalPrice) as average_price from FACT_TRANSACTIONS t
inner join DIM_DATE d on t.Date = d.DATE inner join DIM_CUSTOMER c on t.IDCustomer = c.IDCustomer
group by c.Customer_Name, d.YEAR
having AVG(TotalPrice) > 500 and d.Year = '2009'
order by AVG(TotalPrice) asc

/*7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008,2009 and 2010*/

  Select distinct top  5  Mo.idmodel from FACT_TRANSACTIONS f inner join DIM_MODEL Mo on Mo.IDModel = f.IDModel
		inner join DIM_DATE d on f.Date = d.DATE and d.year in ('2008', '2009', '2010') where f.idmodel in
	(Select top  5 Mo.idmodel from FACT_TRANSACTIONS f inner join DIM_MODEL Mo on Mo.IDModel = f.IDModel
		inner join DIM_DATE d on f.Date = d.DATE and d.year in ('2008')
		group by d.year, Mo.idmodel, mo.model_name
		having mo.idmodel in 
			(Select top  5 Mo.idmodel from FACT_TRANSACTIONS f inner join DIM_MODEL Mo on Mo.IDModel = f.IDModel
			inner join DIM_DATE d on f.Date = d.DATE and d.year in ('2009')
			group by d.year, Mo.idmodel, mo.model_name
			having mo.idmodel in
				(Select top  5 Mo.idmodel from FACT_TRANSACTIONS f inner join DIM_MODEL Mo on Mo.IDModel = f.IDModel
				inner join DIM_DATE d on f.Date = d.DATE and d.year in ('2010')
				group by d.year, Mo.idmodel, mo.model_name order by sum(f.Quantity) desc)
			order by sum(f.Quantity) desc)
		order by sum(f.Quantity) desc)






 /*8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010
 Total Price
 manufacturer Name
 year 2009 and 2010.*/

 select Top 2 (f.TotalPrice), Ma.Manufacturer_Name, d.Year from FACT_TRANSACTIONS f
 inner join Dim_Model Mo on Mo.IdModel = f.IdModel
 inner join Dim_Manufacturer Ma on Ma.IDManufacturer = Mo.IdManufacturer
 inner join Dim_Date d on d.Date = f.Date
 group by f.TotalPrice, Ma.Manufacturer_Name, d.Year
 having d.Year in ('2009','2010') 


 /*9. Show the manufacturers that sold cellphone in 2010 but didn't in 2009 */
 Select distinct Ma.Manufacturer_Name, d.YEAR from Dim_Manufacturer Ma
 inner join Dim_Model Mo on Mo.IDManufacturer = Ma.IDManufacturer
 inner join FACT_TRANSACTIONS f on mo.IDModel = f.IDModel
 inner join Dim_Date d on d.Date = f.Date 
  where d.year = '2010' and  ma.Manufacturer_Name not in
  (Select distinct Ma.Manufacturer_Name from Dim_Manufacturer Ma
 inner join Dim_Model Mo on Mo.IDManufacturer = Ma.IDManufacturer
 inner join FACT_TRANSACTIONS f on mo.IDModel = f.IDModel
 inner join Dim_Date d on d.Date = f.Date 
  where d.year = '2009')


 /*10. find top 100 customers and their average spend, average quantity by each year. also, find the percentage spend in each year.*/

  Select distinct top 100 Cu.Customer_Name, avg(f.TotalPrice) as averagePrice, Avg(f.Quantity) as averageQuantity, 
round(100* sum(f.TotalPrice)/dbo.GetTotalPricePerYear(d.YEAR), 2) as percentage, d.Year from FACT_TRANSACTIONS f 
 inner join Dim_Customer Cu on Cu.IdCustomer = f.IdCustomer 
 inner join Dim_Date d on d.Date = f.Date
 group by d.Year , cu.Customer_Name
 having d.Year in ('2008', '2009', '2010')
 order by cu.Customer_Name desc

 create function GetTotalPricePerYear(@yearD int)
 returns money
 begin
	Declare @Price money
  select @Price = sum(totalprice) from FACT_TRANSACTIONS f inner join DIM_DATE d on f.date = d.date
  where d.YEAR = @yearD
 Return @Price 
 end