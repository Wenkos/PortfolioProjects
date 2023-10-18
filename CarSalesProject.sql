---Inspecting the data
select * from [dbo].[sales_data_sample]

---Checking unique values
select distinct status from [dbo].[sales_data_sample] ---idea
select distinct year_id from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [sales_data_sample] ---idea
select distinct COUNTRY from [sales_data_sample] ---idea
select distinct DEALSIZE from [sales_data_sample] --- idea
select distinct TERRITORY from [sales_data_sample] ----idea

select distinct MONTH_ID from [dbo].[sales_data_sample] --- year 2005 only operated for 5 months
where year_ID = 2003

---Analsys 
---Group sales by product line
select PRODUCTLINE, sum(sales) Revenue
from [dbo].[sales_data_sample]
group by PRODUCTLINE
order by 2 desc

select YEAR_ID, sum(sales) Revenue
from [dbo].[sales_data_sample]
group by YEAR_ID
order by 2 desc

select DEALSIZE, sum(sales) Revenue 
from [PortfolioProject].[dbo].[sales_data_sample]
group by DEALSIZE
order by 2 desc

---What was the best month for sales in a specific year? How much was earned that month?
select MONTH_ID, sum(sales) Revenue, count(ORDERNUMBER) Frequemcy
from [PortfolioProject].[dbo].[sales_data_sample]
where YEAR_ID = 2003
group by MONTH_ID
order by 2 desc

--- November seens to be the best month in 2003, what was the best product, Classic.
select MONTH_ID, PRODUCTLINE, sum(sales) Revenue, count(ORDERNUMBER)
from [PortfolioProject].[dbo].[sales_data_sample]
where YEAR_ID = 2003 and MONTH_ID = 11 --best month in 2003
group by MONTH_ID, PRODUCTLINE
order by 3 desc

---Who is our best customer (Recency-Frequency-Monetary (RFM)

DROP TABLE IF EXISTS #rfm 
;with rfm as
(
	select
		CUSTOMERNAME,
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERDATE) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from [dbo].[sales_data_sample]) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from [dbo].[sales_data_sample])) Recency
	from [PortfolioProject].[dbo].[sales_data_sample]
	group by CUSTOMERNAME
),
rfm_calc as
(

select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary as varchar)rfm_cell_string
into #rfm
from rfm_calc c

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm

---What products are most often sold together?
--- select * from [dbo].[sales_data_sample] where ORDERNUMBER = 10411
	
select distinct OrderNumber, stuff(

	(select ',' + PRODUCTCODE
	from [PortfolioProject].[dbo].[sales_data_sample] p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM [PortfolioProject].[dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from [PortfolioProject].[dbo].[sales_data_sample] s
order by 2 desc