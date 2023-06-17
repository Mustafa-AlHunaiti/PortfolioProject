/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
/*
I'm just going to change the sale date, so it has a time at the end and it serves absolutely no purpose
and it just annoys me I want to take that off
so it's a date time format 
*/

SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing



UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted date

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data 
/*
Property Address could be populated if we had a reference point to base that off
so run this code
Block of code
(
SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID 
)
then look at row 44 and row 45 both have the same ParcelID and the same PropertyAddress.
So something that we can do is basically say if this ParcelID(015 14 0 060.00) has an PropertyAddress(3113  MILLIKEN DR, JOELTON) and
this ParcelID(015 14 0 060.00) does not have an PropertyAddress let's populate it with this PropertyAddress(3113  MILLIKEN DR, JOELTON)
that's already populated because we know these are going to be the same
*/
/*
we're going to have to do with this is do a SELF JOIN we have to join the table to itself to look at for example (row 44 and 45) 
if this ParcelID(015 14 0 060.00) is equal to this if this ParcelID(015 14 0 060.00) 
then this PropertyAddress(3113  MILLIKEN DR, JOELTON) needs to be equal to this PropertyAddress(3113  MILLIKEN DR, JOELTON) 
*/

SELECT *
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID 


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- The ISNULL() function returns a specified value if the expression is NULL. If the expression is NOT NULL, this function returns the expression.
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID -- we said where the ParcelID is the same but it's not the same row 
	AND a.[UniqueID ] <> b.[UniqueID ] -- we need to find a way to distinguish these(for example row 44 and 45) we can use UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID  
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
/* 
if u wanted to do something like that 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, 'No Address')
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID  
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
*/


--------------------------------------------------------------------------------------------------------------------------


-- Breaking out address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress IS NULL
--ORDER BY ParcelID 


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address -- The CHARINDEX() function searches for a substring in a string, and returns the position. If the substring is not found, this function returns 0.
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255) 

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255) 

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




SELECT *
FROM PortfolioProject..NashvilleHousing




SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing



SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255) 

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(255) 

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255) 

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
,CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing 
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'


UPDATE PortfolioProject..NashvilleHousing 
SET SoldAsVacant = 
CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END



--------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates 
/*
WITH RowNumCTE AS
(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 uniqueID
				 ) row_num
FROM PortfolioProject..NashvilleHousing
--WHERE row_num > 1
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
*/

WITH RowNumCTE AS
(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 uniqueID
				 ) row_num
FROM PortfolioProject..NashvilleHousing
--WHERE row_num > 1
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1




SELECT *
FROM PortfolioProject..NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO