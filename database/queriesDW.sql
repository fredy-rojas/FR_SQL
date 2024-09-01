-- SECTION 7

-- Question1: Which product generated maximun sales amounts in December 2019
SELECT 
       i."Product Name",
       i."Total Sales"
FROM (
        SELECT 
                MAX(p.product_name)                             AS "Product Name",
                SUM(s.total_sale)                               AS "Total Sales",
                RANK() OVER (ORDER BY SUM(s.total_sale) DESC)   AS "RANK"
        FROM Sales s, ProductsDW p
        WHERE s.product_id = p.product_id
        AND  s.D_date in (
                            SELECT
                                    c.d_date
                            FROM CalendarDW c
                            Where c.month_name = 'DECEMBER '
                            AND   c.year_yyyy = 2019   
                         ) -- End First Inner Query
        GROUP BY s.product_id
        ) i -- End Second Inner Query
WHERE "RANK" = 1;


-- Question2: Which are the top 3 outlets that produced the highest sales amounts for the whole year?
SELECT 
       inn."Outlet Name",
       inn."Total Sales",
       inn."RANK"
FROM (
        SELECT 
                MAX(o.outlet_name)                              AS "Outlet Name",
                SUM(s.total_sale)                               AS "Total Sales",
                RANK() OVER (ORDER BY SUM(s.total_sale) DESC)   AS "RANK"
        FROM Sales s, OutletsDW o
        WHERE s.outlet_id = o.outlet_id
        AND  s.d_date IN (
                            SELECT
                                    c.d_date
                            FROM CalendarDW c
                            Where c.year_yyyy = 2019    
                          ) -- End First Inner Query
        GROUP BY s.outlet_id -- Understanding that each Outlet ID is a different outlet
        ) inn -- End Second Inner Query
WHERE "RANK" < = 3;


-------------------------------------------------------
-- Question3: Create a materialised view called “OutletAnanlysis_MV” that presents the product?wise
-- sales analysis for each outlet. The results should be ordered by Outlet_ID and then by
-- Product_ID.

DROP MATERIALIZED VIEW OutletAnanlysis_MV;
CREATE MATERIALIZED VIEW OutletAnanlysis_MV AS

    SELECT
            s.outlet_id,
            s.product_id,
            SUM(s.quantity_sold)   AS "UNITS_SALE"
    From Sales s
    GROUP BY s.outlet_id, s.product_id
    ORDER BY s.outlet_id, s.product_id;


-- Confirm output of OutletAnanlysis_MV
SELECT * FROM OutletAnanlysis_MV;

-- --------------------------------------------------------------------
/* 
* Question4: Determine the supplier name for the most popular product (based on sales) for outlet_ID
* S-4. Display the Supplier_Name. Use the materialised view you created (IN QUESTION 3); do not
* recreate the materialised view, you only need to use it here.
*/

-- Acording most unit sold, Most popular
SELECT Distinct
    sp.supplier_name
FROM (
            SELECT 
                mv.OUTLET_ID,
                mv.PRODUCT_ID,
                RANK() OVER (ORDER BY mv."UNITS_SALE" DESC) AS "RANK"
            FROM OutletAnanlysis_MV mv
            WHERE mv.OUTLET_ID = 'S-4'
        )  mv, Sales s, SuppliersDW sp 
WHERE  mv.PRODUCT_ID = s.product_id
AND sp.supplier_id = s.supplier_id
AND mv.OUTLET_ID = 'S-4'
AND "RANK" = 1;

-- ----------------------------------------------------------------------------
-- Question5: Think about what information can be retrieved using ROLLUP or CUBE concepts and provide
-- some useful information of your choice for management.


/* 
* By using ROLLUP is possible to retrieve the Quarters sales SUBTOTAL of 2019 allowing to 
* analyse trends (for example, for Q4 would be expected the Highest sales of 2019, but for this scenario
* is not the case ) and present the 2019 Gran TOTAL on sales.
*/

SELECT 

    CASE WHEN s.outlet_id IS NULL THEN 'TOTAL' ELSE s.outlet_id END             AS "Outlet ID",
    SUM(CASE WHEN c.quarter = 1 AND c.year_yyyy = 2019 THEN s.total_sale END)   AS "2019-Q1",
    SUM(CASE WHEN c.quarter = 2 AND c.year_yyyy = 2019 THEN s.total_sale END)   AS "2019-Q2",
    SUM(CASE WHEN c.quarter = 3 AND c.year_yyyy = 2019 THEN s.total_sale END)   AS "2019-Q3",
    SUM(CASE WHEN c.quarter = 4 AND c.year_yyyy = 2019 THEN s.total_sale END)   AS "2019-Q4",
    SUM(s.total_sale) AS "TOTAL"

FROM SAlES s, CalendarDW c
WHERE s.d_date = c.d_date
GROUP BY ROLLUP(outlet_id);






