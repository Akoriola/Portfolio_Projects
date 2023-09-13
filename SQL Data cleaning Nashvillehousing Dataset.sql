
-- ------------------Cleaning data using sql queries-------------------

select * 
from portfolio_projects..NashvilleHousing

----------------------------------------------------
-- ---------------standardize date format-------------

select SaleDate, CONVERT(Date, SaleDate)
from portfolio_projects..NashvilleHousing


ALTER TABLE NashvilleHousing 
Add SaleDate2 Date

update NashvilleHousing
set SaleDate2 = CONVERT(Date, SaleDate)

--drop saledate column 
ALTER TABLE NashvilleHousing
drop column  SaleDate



---------------------------------------------------------------------
----------------------- populate property Address-------------------- 
select * 
from portfolio_projects..NashvilleHousing
where PropertyAddress is null

--
--select * 
--from portfolio_projects..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


-- 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio_projects..NashvilleHousing a
JOIN portfolio_projects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--update the propertyaddress column
update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio_projects..NashvilleHousing a
JOIN portfolio_projects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---check
select * 
from portfolio_projects..NashvilleHousing
where PropertyAddress is null
--The PropertyAddress column is fully populated



----------------------------------------------------------------

-----------Breaking out Address into different columns of (Address, city, state)---------------

select PropertyAddress 
from portfolio_projects..NashvilleHousing

-----break out usisng the substring function---


--OR
 --select 

 --PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)
 --,PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)
--from portfolio_projects..NashvilleHousing


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

from portfolio_projects..NashvilleHousing

--create new column and update the changes
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)
	

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

 --check
 select *
 from portfolio_projects..NashvilleHousing

 ------------Break out the OwnerAddress column too using PASRENAME function-----------

 select OwnerAddress
 from portfolio_projects..NashvilleHousing

 --
 select 
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from portfolio_projects..NashvilleHousing


--create new column and update the changes
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)
	
	

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Update NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Update NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

 --check
 select *
 from portfolio_projects..NashvilleHousing




 --------------------------------------------------------------------------

 -------------Change N and Y to No and Yes in SoldAsVacant column-----------
--unique values count of the column
select DIstinct(SoldAsVacant), count(SoldAsVacant)
from portfolio_projects..NashvilleHousing
Group by SoldAsVacant
order by 2

--replace N and Y with No and Yes

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from portfolio_projects..NashvilleHousing

--update chnages
Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--check
select DIstinct(SoldAsVacant), count(SoldAsVacant)
from portfolio_projects..NashvilleHousing
Group by SoldAsVacant
order by 2


-----------------------------------------------------------------
---------------------Remove duplicates-----------------
--checking for duplicates

WITH rn_cte AS (
  SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate2, LegalReference
  ORDER BY UniqueID) AS rn
from portfolio_projects..NashvilleHousing 
)
Select * 
From rn_cte
Where rn > 1;


---drop the duplicates
WITH rn_cte AS (
  SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate2, LegalReference
  ORDER BY UniqueID) AS rn
from portfolio_projects..NashvilleHousing 
)
Delete
From rn_cte
Where rn > 1;



--------------------------------------------------------------------------
----------Delete Unused columns-----------
select *
 from portfolio_projects..NashvilleHousing

ALTER TABLE portfolio_projects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress