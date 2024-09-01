-- CREATION OF TABLES (DIMENSION AND FACT TABLES) FOR THE DATA WAREHOUSE

DROP TABLE Sales;       COMMIT;
DROP TABLE CustomersDW; COMMIT;
DROP TABLE OutletsDW;   COMMIT;
DROP TABLE ProductsDW;  COMMIT;
DROP TABLE SuppliersDW; COMMIT;
DROP TABLE CalendarDW;  COMMIT;


-- Creating Dimension. 
CREATE TABLE CustomersDW 
        (
        customer_id         VARCHAR2(4)     PRIMARY KEY,
        customer_name       VARCHAR2(24)
        );
COMMIT;

CREATE TABLE OutletsDW
        (
        outlet_id           VARCHAR2(4)     PRIMARY KEY,
        outlet_name         VARCHAR2(20)
        );
COMMIT; 

CREATE TABLE ProductsDW
        (
        product_id          VARCHAR2(6)     PRIMARY KEY,
        product_name        VARCHAR2(28),
        sale_price          NUMBER(5,2)
        );
COMMIT;

CREATE TABLE SuppliersDW
        (
        supplier_id         VARCHAR2(5)     PRIMARY KEY,
        supplier_name       VARCHAR2(30)
        );
 COMMIT; 

CREATE Table CalendarDW
    (
    d_date          DATE            Primary Key,
    day_name        VARCHAR2(15),
    week_numb       VARCHAR2(15),
    month_name      VARCHAR2(15),
    quarter         VARCHAR2(15),
    year_yyyy       NUMBER(4,0)
    );
COMMIT;

-- FACT TABLE:
CREATE TABLE Sales
        (
        datastream_id       NUMBER(8,0),
        customer_id         VARCHAR2(4),
        outlet_id           VARCHAR2(4),
        product_id          VARCHAR2(6),
        supplier_id         VARCHAR2(5),
        d_date              DATE,
        quantity_sold       NUMBER(3,0),
        total_sale          NUMBER(5,2),
        
        
        CONSTRAINT  s_cusotmer_id       FOREIGN KEY(customer_id)    REFERENCES CustomersDW  (customer_id),
        CONSTRAINT  s_outlet_id         FOREIGN KEY(outlet_id)      REFERENCES OutletsDW    (outlet_id),
        CONSTRAINT  s_product_id        FOREIGN KEY(product_id)     REFERENCES ProductsDW   (product_id),
        CONSTRAINT  s_supplier_id       FOREIGN KEY(supplier_id)    REFERENCES SuppliersDW  (supplier_id),
        CONSTRAINT  s_d_date            FOREIGN KEY(d_date)         REFERENCES CalendarDW   (d_date)       
        );
COMMIT;

--------------------------------------------------------------------------------------------------------------
-- Insert Dates into the dimension TIME (calendar)
Declare
    Counter Int;
    N_date DATE := '31/12/17'; 
Begin
    
    For counter in 1 .. 1096 
        Loop
        Insert Into CalendarDW(d_date, day_name, week_numb, month_name, quarter, year_yyyy )
            Values (   N_date + counter, 
                        to_Char(N_date + counter, 'DAY'),
                        to_Char(N_date + counter, 'WW'),
                        TO_char(N_date + counter, 'MONTH'),
                        TO_char(N_date + counter, 'Q'),
                        TO_char(N_date + counter, 'yyyy')
                    );
    End Loop; 
End;
COMMIT;