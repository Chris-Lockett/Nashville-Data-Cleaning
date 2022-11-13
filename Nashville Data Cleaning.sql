SELECT * FROM NVHD.housing;

/* Populate all addresses that are NULL in the PropertyAddress column */

SELECT *
FROM housing
WHERE PropertyAddress IS NULL;

-- Self join to compare NULL addresses with the same parcel to 2nd table. ISNULL -> IFNULL(Mysql Version)
-- IFNULL(If value is NULL, What needs to be placed in NULL value)

SELECT h1.ParcelID, 
	   h1.PropertyAddress, 
       h2.ParcelID, 
       h2.PropertyAddress, 
       IFNULL(h1.PropertyAddress, h2.PropertyAddress) AS CorrectAddress
FROM housing h1
JOIN housing h2
	ON h1.ParcelID = h2.ParcelID
    AND
    h1.UniqueID != h2.UniqueID
WHERE h1.PropertyAddress IS NULL;

-- Updating the NULL values with query above

UPDATE housing h1
       JOIN housing h2
       ON h1.ParcelID = h2.ParcelID
       AND
       h1.UniqueID != h2.UniqueID
SET h1.PropertyAddress = IFNULL(h1.PropertyAddress, h2.PropertyAddress)
WHERE h1.PropertyAddress IS NULL;


/* Checking the SUBSTRING_INDEX query to split the address into two columns */

SELECT 
  SUBSTRING_INDEX(PropertyAddress, ',', 1) 
    AS Address,
    SUBSTRING_INDEX(PropertyAddress, ',', -1) 
    AS City
    FROM housing;
    
-- Adding new address column to housing table 
    
ALTER TABLE housing    
ADD SplitPropertyAddress VARCHAR(255);

-- Adding address data to new column

UPDATE housing
SET SplitPropertyAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

-- Adding new city column to housing table 

ALTER TABLE housing    
ADD SplitCityAddress VARCHAR(255);      
    
-- Adding city data to new column

UPDATE housing
SET SplitCityAddress = SUBSTRING_INDEX(PropertyAddress, ',', -1);    
    
-- Checking to see how many different answers populate    
    
SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM housing
GROUP BY SoldAsVacant;

-- Creating case statment to change all 'N' to 'No' & 'Y' to 'Yes'
    
SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END 
FROM housing
GROUP BY SoldAsVacant;

-- Updating the SoldAsVacant column 'N' to 'No' & 'Y' to 'Yes'

UPDATE housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END;
    
    
/* Separating the first and last name for the OwnerName column*/     
    
SELECT 
  SUBSTRING_INDEX(OwnerName, ',', -1) 
    AS FirstName,
    SUBSTRING_INDEX(OwnerName, ',', 1) 
    AS LastName
    FROM housing;    
    
-- Adding OwnerFirstName column to housing table
    
ALTER TABLE housing
ADD OwnerFirstName VARCHAR(255);   

-- Updating OwnerFirstName column to housing table
    
UPDATE housing
SET OwnerFirstName = SUBSTRING_INDEX(OwnerName, ',', -1);  

-- Adding OwnerLastName column to housing table
  
ALTER TABLE housing
ADD OwnerLastName VARCHAR(255); 
    
-- Updating OwnerLastName column to housing table
    
UPDATE housing
SET OwnerLastName = SUBSTRING_INDEX(OwnerName, ',', 1);     
    
    
/* Separating the owners address into Address, City and State */    
    
SELECT 
  SUBSTRING_INDEX(OwnerAddress, ',', 1) 
    AS OwnerAddress,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',', -1)
    AS OwnerCity,
  SUBSTRING_INDEX(OwnerAddress, ',', -1) 
    AS OwnerState
FROM housing;

-- Adding new column (OwnerAddress) to housing

ALTER TABLE housing
ADD OwnerSplitAddress VARCHAR(255);

 -- Updating new column (OwnerAddress) to housing
 
UPDATE housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

-- Adding new column (OwnerCity) to housing

ALTER TABLE housing
ADD OwnerSplitCity VARCHAR(255);

-- Updating new column (OwnerCity) to housing

UPDATE housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',', -1);

-- Adding new column (OwnerState) to housing

ALTER TABLE housing
ADD OwnerSplitState VARCHAR(255);

-- Updating new column (OwnerState) to housing

UPDATE housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


/* Dropping unused columns */

ALTER TABLE housing
  DROP COLUMN PropertyAddress,
  DROP COLUMN OwnerName,
  DROP COLUMN OwnerAddress;