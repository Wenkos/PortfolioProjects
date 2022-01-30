/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

-- Cleaning Data in SQL Queries
 
Select *
FROM [PortfolioProject].[dbo].[NashvilleHousing]



-- Standardize Data Format

Select SaleDateConverted, CONVERT(Date, Saledate)
FROM [PortfolioProject].[dbo].[NashvilleHousing]

Update NashvilleHousing
SET Saledate = CONVERT(Date, Saledate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConveerted = CONVERT(Date, Saledate)


-- Populating Property Address Data

Select *
FROM [PortfolioProject].[dbo].[NashvilleHousing]  
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] a 
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM [PortfolioProject].[dbo].[NashvilleHousing] a 
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking Out Address Into Individual Colums (Address, City, State)


Select SaleDateConverted, CONVERT(Date, Saledate)
FROM [PortfolioProject].[dbo].[NashvilleHousing]


-- Where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM [PortfolioProject].[dbo].[NashvilleHousing]



ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add PropertySplitCity Nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 




Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME (REPLACE(OwnerAddress, ',', '.') , 1)
FROM [PortfolioProject].[dbo].[NashvilleHousing]



ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitState Nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM [PortfolioProject].[dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2


Select OwnerAddress
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [PortfolioProject].[dbo].[NashvilleHousing]


Update [PortfolioProject].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-- Removing Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [PortfolioProject].[dbo].[NashvilleHousing]
--order by ParcelID
)
DELETE
From RowNUMCTE
Where row_num > 1
--Order by PropertyAddress



-- Delete UnUsed Columns

Select *
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
DROP COLUMN SaleDate