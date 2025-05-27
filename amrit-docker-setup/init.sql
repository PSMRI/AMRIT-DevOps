-- Create databases if they don't exist
CREATE DATABASE IF NOT EXISTS db_iemr;
CREATE DATABASE IF NOT EXISTS db_identity;
CREATE DATABASE IF NOT EXISTS db_reporting;
CREATE DATABASE IF NOT EXISTS db_1097_identity;

-- Create database user with privileges
CREATE USER IF NOT EXISTS '${DATABASE_USERNAME}'@'%' IDENTIFIED BY '${DATABASE_PASSWORD}';

-- Grant privileges to the user for all databases
GRANT ALL PRIVILEGES ON db_iemr.* TO '${DATABASE_USERNAME}'@'%';
GRANT ALL PRIVILEGES ON db_identity.* TO '${DATABASE_USERNAME}'@'%';
GRANT ALL PRIVILEGES ON db_reporting.* TO '${DATABASE_USERNAME}'@'%';
GRANT ALL PRIVILEGES ON db_1097_identity.* TO '${DATABASE_USERNAME}'@'%';

-- Apply changes
FLUSH PRIVILEGES;

-- Create required views
USE db_iemr;

CREATE OR REPLACE VIEW v_emailstockalert AS
SELECT 
    UUID() as uuid,
    i.totalQuantity as Totalquantity,
    i.createdBy as CreatedBy,
    d.districtName as DistrictName,
    u.emailID as Emailid,
    f.facilityID as FacilityId,
    f.facilityName as FacilityName,
    im.itemID as ItemID,
    im.itemName as ItemName,
    i.quantityInHand as Quantityinhand,
    ROUND((i.quantityInHand / i.totalQuantity) * 100, 2) as QuantityinhandPercent
FROM m_facility f
JOIN m_district d ON f.districtID = d.districtID
JOIN m_user u ON f.facilityID = u.facilityID
JOIN t_itemstock i ON f.facilityID = i.facilityID
JOIN m_item im ON i.itemID = im.itemID
WHERE i.deleted = FALSE
AND i.quantityInHand <= (i.totalQuantity * 0.2); 