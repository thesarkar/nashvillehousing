-- Cleaning data in SQL queries
Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format
Select SaleDateConverted,CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data
--Check for NULL Values
Select *
From PortfolioProject..NashvilleHousing
where PropertyAddress is Null


/*
The Address values with NULL have same parcel IDs. 
So, adding the address where parcel Ids match using Join

*/
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID= b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


--Updating the address in the table


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID= b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


--Seperating Address into Individual columns
--First Method by using Substring

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress,1,
CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress, 
CHARINDEX(',',PropertyAddress)+1,
LEN(PropertyAddress)) as Address 

From PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);


Update NashvilleHousing
Set PropertySplitAddress =Substring(PropertyAddress, 1 ,
Charindex(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



--Second Method by using PARSENAME	
--PARSENAME only works with periods(.)

Select *
From PortfolioProject..NashvilleHousing

Select OwnerAddress
From PortfolioProject..Nashvillehousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing



Use PortfolioProject
Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);


Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *
From PortfolioProject..NashvilleHousing



--Change Y and N to Yes and No in Sold as Vacant column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End



---Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by
			UniqueId)
		row_num

From PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Deleting the duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by
			UniqueId)
		row_num

From PortfolioProject..NashvilleHousing
)

Delete
From RowNumCTE
Where row_num > 1


--Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN TaxDistrict, Acreage