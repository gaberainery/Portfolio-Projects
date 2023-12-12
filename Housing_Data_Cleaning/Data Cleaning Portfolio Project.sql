/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
-- Standarize Date Format

Select SaleDateConverted, Convert(date,saledate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
Set SaleDate = Convert(date,SaleDate)
	
-- SaleDate was not updating to new format so Alter Table was used
	
Alter Table NashvilleHousing 
Add SaleDateConverted Date; 

Update NashvilleHousing
Set SaleDateConverted = Convert(date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

	

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISnull(a.PropertyAddress,b.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISnull(a.PropertyAddress,b.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(propertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


	
Alter Table NashvilleHousing 
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

	
Alter Table NashvilleHousing 
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(propertyAddress))


	
Select *
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing



Alter Table NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

	
Alter Table NashvilleHousing 
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

	
Alter Table NashvilleHousing 
Add OwnerSplitState  Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitState  =  PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


	
Select *
From PortfolioProject.dbo.NashvilleHousing

	
--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" Field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2 


	
Select SoldAsVacant
, Case when SoldAsVacant = 'y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing
	

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   End


-------------------------------------------------
-- Remove Duplicates

With RowNumCTE AS (
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) Row_Num



From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)

Select *
From RowNumCTE
Where Row_Num >1
Order by PropertyAddress


Select*
From PortfolioProject.dbo.NashvilleHousing


----------------------------------------------------
-- Delete Unused Columns


Select*
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


