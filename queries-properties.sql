--General property lookup query
SELECT p.idProperties, p.address, p.address2,
p.city, p.state, p.postalCode,
p.leaseStatus, p.forSaleStatus, t.tenantName,
l.commencement, l.expiration, l.rate,
PERIOD_DIFF(date_format(l.expiration, '%Y%m'), date_format(CURDATE(), '%Y%m')) AS MonthsLeft,
l.active, l.tripleNet, pr.projectName
FROM properties AS p
LEFT JOIN leases AS l
	ON p.idProperties = l.idProperties
LEFT JOIN tenants AS t
	ON l.idTenants = t.idTenants
LEFT JOIN projects AS pr
	ON p.idProjects = pr.idProjects
WHERE l.active = 1
ORDER BY pr.projectName, p.address, p.address2

--General property infomation by idProperties
SELECT p.idProperties, p.address, p.address2, p.city, p.state, p.postalCode, p.esid, p.meterNumber, p.buildingSize, p.lotSize, p.yearBuilt, p.leaseStatus, p.forSaleStatus,
t.tenantName, l.commencement, l.expiration, l.rate,
PERIOD_DIFF(date_format(l.expiration, '%Y%m'), date_format(CURDATE(), '%Y%m')) AS MonthsLeft, pr.projectName
FROM properties AS p
LEFT JOIN leases AS l
	ON p.idProperties = l.idProperties
LEFT JOIN tenants AS t
	ON l.idTenants = t.idTenants
LEFT JOIN projects AS pr
	ON p.idProjects = pr.idProjects
WHERE p.idProperties = 

--Leases for idProperties

/*
*	Queries that are used for creating For Sale information*
*/
-- Property Summary Query
-- Emulates the MSWord document
-- Look at creating a view
SELECT p.idProperties, p.address, f.price, p.lotSize, p.buildingSize, p.officeSize, p.yearBuilt,
f.forSaleDescription, l.rate, l.commencement, l.expiration,
PERIOD_DIFF(date_format(l.expiration, '%Y%m'), date_format(l.commencement, '%Y%m')) + 1 AS leaseTerm, t.tenantName
FROM properties AS p
LEFT JOIN forSale AS f
	ON p.idProperties = f.idproperties
LEFT JOIN leases AS l
	ON p.idProperties = l.idproperties
LEFT JOIN tenants AS t
	ON l.idTenants = t.idTenants
WHERE p.forSaleStatus = 'For Sale'
AND l.active = 1

--MS Excel Spreadsheet emulator
--Close still need to modify a few things, (take a look at current spreadsheet.)
SELECT p.idProperties, t.idTenants, f.idForSale, p.address, t.tenantName, t.webaddress, p.buildingSize, p.officeSize, p.lotSize, l.commencement,
PERIOD_DIFF(date_format(l.expiration, '%Y%m'), date_format(l.commencement, '%Y%m')) + 1 AS leaseTerm,
 (l.rate * 12) AS AnnualRate, f.price
FROM properties AS p
LEFT JOIN leases AS l
	ON p.idProperties = l.idProperties
LEFT JOIN tenants AS t
	ON l.idTenants = t.idTenants
LEFT JOIN forSale AS f
	ON p.idProperties = f.idproperties
WHERE p.forSaleStatus = 'For Sale'
ORDER BY f.idForSale

--Change for properties that are Under Contract
UPDATE properties SET forSaleStatus = 'Under Contract'
WHERE idProperties IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,26,27,28,30,31,33,81,165,164)

--Change properties that were marked as Under Contract that need to be changed back.
UPDATE properties SET forSaleStatus = 'For Sale'
WHERE idProperties IN (2,3,5,6,9,16,17,18,19,20,21,22,23,24,28,31,33,81,165,164)


/*
*	Occupancy Report Queries
*/
--Occupancy Report Query for Absolute Storage from Access
SELECT P.Suite AS Unit_Number,
P.Occupancy, P.Length,
P.Width, (P.Length*P.Width) AS SqFeet,
P.Type, T.CompanyName AS Leased_To,
P.Expiration, (P.Rate+P.Fee) AS Rate,
P.ESI, P.Note, T.EmailAddress
FROM Properties AS P
LEFT JOIN Tenants AS T
	ON P.TenantID = T.tenantID
WHERE (((P.Project)=1))
ORDER BY P.Building, P.Suite;

--Absolute Nationwide Storage
SELECT p.address2, p.leaseStatus,
(l.rate + l.fees) AS rate,
p.buildingSize AS BuildingSize,
l.commencement, l.expiration,
t.tenantName
FROM properties AS p
LEFT JOIN leases AS l
	ON p.idProperties = l.Properties_idProperties
LEFT JOIN tenants AS t
	ON l.Tenants_idTenants = t.idTenants
LEFT JOIN forSale AS f
	ON p.idProperties = f.properties_idproperties
WHERE p.Projects_idProjects = 6
AND l.active = 1

--Princeton
SELECT p.idProperties, l.idLeases, t.idTenants,
p.address, p.address2, p.leaseStatus,
l.rate, l.commencement, l.expiration,
t.tenantName
FROM properties AS p
LEFT JOIN leases AS l
	ON p.idProperties = l.Properties_idProperties
LEFT JOIN tenants AS t
	ON l.Tenants_idTenants = t.idTenants
LEFT JOIN forSale AS f
	ON p.idProperties = f.properties_idproperties
WHERE p.Projects_idProjects = 5
AND l.active = 1

/*
*	 INSERTS
*/
--Tenant Information
INSERT INTO tenants (tenantName, contactFirstName, contactLastName, address, city, state, postalCode, country, phonePrimary, phoneSecondary, phoneMobile, faxPrimary, email, webAddress)
VALUES ('tenantName', 'contactFirstName', 'contactLastName', 'address', 'city', 'state', 'postalCode', 'country', 'phonePrimary', 'phoneSecondary', 'phoneMobile', 'faxPrimary', 'email', 'webAddress')

--Lease Information
INSERT INTO leases (commencement, expiration, rate, fees, active, tripleNet, firstRightRefusal, purchaseOption, Tenants_idTenants, Properties_idProperties)
VALUES ('YYYY-MM-DD', 'YYYY-MM-DD', 0.00, 0.00, 1, 1, 0, 0, Tenants_idTenants, Properties_idProperties)

--Tenants Contact Information
INSERT INTO tenantscontacts (firstName, lastName, position, phonePrimary, phoneSecondary, phoneMobile, faxPrimary, email, Tenants_idTenants)
VALUES ('firstName', 'lastName', 'position', 'phonePrimary', 'phoneSecondary', 'phoneMobile', 'faxPrimary', 'email', Tenants_idTenants)



--Querys to find www domain names for tenants email address.
SELECT (
SUBSTRING_INDEX(SUBSTR(email, INSTR(email, '@')+1),'.',1))
FROM tenants

SELECT SUBSTR(email, INSTR(email, '@') + 1)
FROM tenants

SELECT
CONCAT(phoneAreaCode, '-', phonePrefix, '-', phoneLine) AS phonePrimary,
CONCAT(faxAreaCode, '-', faxPrefix, '-', faxLine) AS phoneMobile,
CONCAT('http://www.', SUBSTR(email, INSTR(email, '@') + 1)) AS webpage
FROM tenants

UPDATE tenants SET webaddress = (SELECT CONCAT('http://www.', SUBSTR(email, INSTR(email, '@') + 1)))
UPDATE tenants SET phonePrimary = (CONCAT(phoneAreaCode, '-', phonePrefix, '-', phoneLine))
UPDATE tenants SET phoneMobile = (CONCAT(faxAreaCode, '-', faxPrefix, '-', faxLine))
UPDATE tenants SET webaddress = (SELECT SUBSTR(webaddress,8))

SELECT webaddress, count(webaddress) AS Count
FROM tenants
GROUP BY webaddress
ORDER BY Count DESC