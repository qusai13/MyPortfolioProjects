/*

Cleaning Data In SQL Queries

*/

Select *
From NashvilleHousing

------------------------------------------------------------------------------------------------------------

/* Standarize SalesDate */

Select SaleDate_1 , CONVERT(date,SaleDate) AS SaleDate
From NashvilleHousing

ALTER Table NashvilleHousing
Add SaleDate_1 date

Update NashvilleHousing
SET SaleDate_1= CONVERT(date,SaleDate) 


------------------------------------------------------------------------------------------------------------


/* Populate Property Address Data */

Select *
from NashvilleHousing
--where PropertyAddress Is Null
order by ParcelID

Select a.[UniqueID ],a.ParcelID,a.PropertyAddress,b.[UniqueID ],b.ParcelID,b.PropertyAddress
From NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Not Null

Update a
SET a.PropertyAddress=b.PropertyAddress
From NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null

/* Explaination for above : In our dataset we notice that we have rows with same ParcelID but different UniqueID one has property 
adress and the other one does not , so by joining the same table with Itself on two aspects :
same ParcelId but Different UniqueID we could populate the Null cells of property address */


------------------------------------------------------------------------------------------------------------


/* Breaking out address Into individual columns (Address , City , State) */

Select PropertyAddress
from NashvilleHousing
--where PropertyAddress Is Null
--order by ParcelID
Select PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) Address1,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) Address2,
CHARINDEX(',', PropertyAddress)
From NashvilleHousing

ALTER Table NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) 

ALTER Table NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))  

------------------------------------------------------------------------------------------------------------
/*Complex method to have multiple substrings  from one string */

Select OwnerAddress,
SUBSTRING(OwnerAddress,1,CHARINDEX(',', OwnerAddress) - 1) as Address,
SUBSTRING(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress)), 1,CHARINDEX(',', SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress))) - 1) as City,
SUBSTRING(OwnerAddress, LEN(OwnerAddress)-2, CHARINDEX(',', OwnerAddress) - 1) AS State
from NashvilleHousing
Where OwnerAddress Is Not Null


/*Different method to have multiple substrings  from one string using PARSENAME function , It divides only on periods , so we changed every comma into a period */


Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousing
Where OwnerAddress Is Not Null


ALTER Table NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER Table NashvilleHousing
Add OwnerSplitCity NVARCHAR(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER Table NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 





/* Change Y and N to Yes and No In 'Sold as vacant' feild */

SELECT Distinct(SoldAsVacant),Count(SoldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant
Order by 2
	
Update NashvilleHousing
set SoldAsVacant =
CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
    END 


/* Remove duplicate rows */

WITH CTE_ROW as (
Select *,
ROW_NUMBER() Over (Partition by ParcelID,PropertyAddress,Saledate,SalePrice,LegalReference Order By UniqueID) row_num

FROM NashvilleHousing 
) 
Select *
From CTE_ROW
Where row_num > 1
--Order by PropertyAddress


-------------------------------------------------------------------------------------

/* Delete Unused columns */


Select *
From NashvilleHousing


ALTER TABLE NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
