-- INJL OPERATOR FOR DW_Electronic Sales

DECLARE

        -- VARIABLES
        MD_ProductID        MasterData.product_id%TYPE;
        MD_ProductName      MasterData.product_name%TYPE;
        MD_SalesPrice       MasterData.sale_price%TYPE;
        
        MD_SupplierID       MasterData.supplier_id%TYPE;
        MD_SupplierName     MasterData.supplier_name%TYPE;

        -- CURSOR NAME
        CURSOR DS_Cursor IS 
                SELECT * 
                FROM DataStream;
        
        -- COLLECTION      
        TYPE DS_Collection IS TABLE OF DS_Cursor%ROWTYPE;
        Vr_CollectionDS DS_Collection;
        
        --Counter
        Counter INT;

BEGIN
        OPEN DS_Cursor;
        
        -- STEP1 INJL: READ 100 TUPLES FROM DATASTREAM
        LOOP
            FETCH DS_Cursor BULK COLLECT INTO Vr_CollectionDS LIMIT 100;
            EXIT WHEN DS_Cursor%NOTFOUND;
            
                -- STEP2 INJL: Compare 1 BY 1 TUPLE OF METADATA WITH 
                --             GROUP OF 100 TUPLES OF DATASTREAM
                FOR i in Vr_CollectionDS.FIRST .. Vr_CollectionDS.LAST
                
                    LOOP
                        SELECT 
                                product_id,
                                product_name,
                                sale_price,
                                supplier_id,
                                supplier_name
                        INTO
                                MD_ProductID,
                                MD_ProductName,
                                MD_SalesPrice,
                                MD_SupplierID,
                                MD_SupplierName
        
                        FROM    MasterData
                        WHERE   product_id = Vr_CollectionDS(i).product_id;
                        

                        -- STEP3 INJL: BEFORE INSERT VALUE CHECK IF THE DIMENSION ProductsDW ALREADY HAVE THE VALUE
                        SELECT COUNT(*) INTO Counter FROM ProductsDW
                        WHERE ProductsDW.product_id = Vr_CollectionDS(i).product_id;
                        IF Counter = 0 THEN
                        INSERT INTO ProductsDW(product_id, product_name, sale_price)   
                            VALUES  (Vr_CollectionDS(i).product_id, MD_ProductName, MD_SalesPrice);
                        END IF;
                        
                        
                        -- STEP3 INJL: BEFORE INSERT VALUE CHECK IF THE DIMENSION CustomersDW ALREADY HAVE THE VALUE
                        SELECT COUNT(*) INTO Counter FROM CustomersDW
                        WHERE CustomersDW.customer_id = Vr_CollectionDS(i).customer_id;
                        IF Counter = 0 THEN
                        INSERT INTO CustomersDW(customer_id, customer_name)   
                            VALUES  (Vr_CollectionDS(i).customer_id, Vr_CollectionDS(i).customer_name);
                        END IF;
                        
                        
                        -- STEP3 INJL: BEFORE INSERT VALUE CHECK IF THE DIMENSION OutletsDW ALREADY HAVE THE VALUE
                        SELECT COUNT(*) INTO Counter FROM OutletsDW
                        WHERE OutletsDW.outlet_id = Vr_CollectionDS(i).outlet_id;
                        IF Counter = 0 THEN
                        INSERT INTO OutletsDW(outlet_id, outlet_name)   
                            VALUES  (Vr_CollectionDS(i).outlet_id, Vr_CollectionDS(i).outlet_name);
                        END IF;
                        
                        
                        -- STEP3 INJL: BEFORE INSERT VALUE CHECK IF THE DIMENSION SuppliersDW ALREADY HAVE THE VALUE
                        SELECT COUNT(*) INTO Counter FROM SuppliersDW
                        WHERE SuppliersDW.supplier_id = MD_SupplierID; -- From Tuple from MasterData
                        IF Counter = 0 THEN
                        INSERT INTO SuppliersDW(supplier_id, supplier_name)   
                            VALUES  (MD_SupplierID, MD_SupplierName);
                        END IF;
                        
                        
                        -- DIMENSION TIME: SPECIAL CASE -- CALENDARDW HAVE BEEN CREATED AS DIMENSION
                        -- CALENDARDW TABLE Primary Key IS d_date
                        
                        
                        -- STEP3 INJL: BEFORE INSERT VALUE CHECK IF THE DIMENSION Sales ALREADY HAVE THE VALUE
                        SELECT COUNT(*) INTO Counter FROM Sales
                        WHERE Sales.datastream_id = Vr_CollectionDS(i).datastream_id; 
                        IF Counter = 0 THEN
                        INSERT INTO Sales   (datastream_id,    customer_id, 
                                            outlet_id,          product_id, 
                                            supplier_id,        d_date, 
                                            quantity_sold,      total_sale)   
                            VALUES  (Vr_CollectionDS(i).datastream_id,      Vr_CollectionDS(i).customer_id, 
                                    Vr_CollectionDS(i).outlet_id,           Vr_CollectionDS(i).product_id, 
                                    MD_SupplierID,                          Vr_CollectionDS(i).d_date, 
                                    Vr_CollectionDS(i).quantity_sold,       Vr_CollectionDS(i).quantity_sold*MD_SalesPrice);
                        END IF;                        
                        COMMIT;
                        
                END LOOP;
                COMMIT;
                
        END LOOP;
        COMMIT;
        
        CLOSE DS_Cursor;

END;









