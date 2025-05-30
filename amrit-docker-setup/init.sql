-- Create databases
CREATE DATABASE IF NOT EXISTS db_iemr;
CREATE DATABASE IF NOT EXISTS db_identity;
CREATE DATABASE IF NOT EXISTS db_reporting;
CREATE DATABASE IF NOT EXISTS db_1097_identity;

-- Create user with proper privileges
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';

-- Grant privileges
GRANT ALL PRIVILEGES ON db_iemr.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON db_identity.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON db_reporting.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON db_1097_identity.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES;

-- Create required views
USE db_iemr;

-- Drop view if exists to avoid errors
DROP VIEW IF EXISTS v_emailstockalert;

-- Create the view with error handling
CREATE OR REPLACE VIEW v_emailstockalert AS
SELECT 
    UUID() as uuid,
    COALESCE(i.totalQuantity, 0) as Totalquantity,
    i.createdBy as CreatedBy,
    d.districtName as DistrictName,
    u.emailID as Emailid,
    f.facilityID as FacilityId,
    f.facilityName as FacilityName,
    im.itemID as ItemID,
    im.itemName as ItemName,
    COALESCE(i.quantityInHand, 0) as Quantityinhand,
    CASE 
        WHEN i.totalQuantity > 0 THEN ROUND((i.quantityInHand / i.totalQuantity) * 100, 2)
        ELSE 0 
    END as QuantityinhandPercent
FROM m_facility f
LEFT JOIN m_district d ON f.districtID = d.districtID
LEFT JOIN m_user u ON f.facilityID = u.facilityID
LEFT JOIN t_itemstock i ON f.facilityID = i.facilityID AND i.deleted = FALSE
LEFT JOIN m_item im ON i.itemID = im.itemID
WHERE i.quantityInHand <= (i.totalQuantity * 0.2)
OR i.quantityInHand IS NULL; 