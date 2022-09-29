
select *
from PortfolioProject..NashvilleHousing

-- changing sale date
select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

select SaleDateConverted
from PortfolioProject..NashvilleHousing

-- populating property adress when its null by using parcelid as a link to fill it

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--using a self join to join parcelid to property address
select h.ParcelID, h.PropertyAddress, n.ParcelID, n.PropertyAddress, ISNULL(h.PropertyAddress, n.PropertyAddress)
from PortfolioProject..NashvilleHousing h
join PortfolioProject..NashvilleHousing n
	on h.ParcelID = n.ParcelID
	and h.[UniqueID ] <> n.[UniqueID ]
where h.PropertyAddress is null

-- updating the table 
update h
SET PropertyAddress = ISNULL(h.PropertyAddress, n.PropertyAddress)
from PortfolioProject..NashvilleHousing h
join PortfolioProject..NashvilleHousing n
	on h.ParcelID = n.ParcelID
	and h.[UniqueID ] <> n.[UniqueID ]
where h.PropertyAddress is null

--splitting the adress into state, city and address
select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null

--separating using charindex and comma as delimeter
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add Propertysplitaddress NVarchar(255);

update NashvilleHousing
SET Propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add Propertysplitcity NVarchar(255);

update NashvilleHousing
SET Propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--checking that the two new columns have been added to the table
select *
from PortfolioProject..NashvilleHousing

--splitting owner address into individual component
select OwnerAddress
from PortfolioProject..NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress, ',','.'), 3), PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add Ownersplitaddress NVarchar(255);

update NashvilleHousing
SET Ownersplitaddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add Ownersplitcity NVarchar(255);

update NashvilleHousing
SET Ownersplitcity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add Ownersplitstate NVarchar(255);

update NashvilleHousing
SET Ownersplitstate = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

--checking that the three new columns have been added to the table
select *
from PortfolioProject..NashvilleHousing

--Checking the soldasvacant columnn for distinct response
select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant

--changing the Y & N to yes and no
select SoldAsVacant, case when SoldAsVacant = 'Y' THEN 'Yes'
						when SoldAsVacant = 'N' THEN 'No'
						else SoldAsVacant END
from PortfolioProject..NashvilleHousing

-- updating the table
UPDATE NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
						when SoldAsVacant = 'N' THEN 'No'
						else SoldAsVacant END

--removing duplicates
WITH RowNumCTE AS(
select *, ROW_NUMBER() over (
		PARTITION BY ParcelID, PropertyAddress, SalePrice,
					SaleDate, LegalReference
					ORDER BY UniqueID) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID 
)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1
--order by PropertyAddress

--checking if the duplicates still exist after deleting
SELECT *
FROM RowNumCTE
WHERE row_num > 1
order by PropertyAddress

--deleting unused columns
SELECT *
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
