-----------------------------------------------------------------------------------------------
--A selection of queries on the NAshville Housing Market DataSet




-- Prints entire dataset to screen for inspection

Select *
FROM ..NashvilleHousing

-----------------------------------------------------------------------------------------------

--Here I standardize date format by creating a new Converted Date column witht the time ommitted.


Alter table ..NashvilleHousing
Add SaleDateConverted Date;

Update ..NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

Select convert(Date, SaleDate) as SaleDateConverted
From [Nashville Housing Market].dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------

--Fixing missing and incorrect address info

Select *
From ..NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From ..NashvilleHousing a
Join ..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From ..NashvilleHousing a
Join ..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Select *
FROM ..NashvilleHousing
WHERE PropertyAddress is null

---------------------------------------------------------------------------------------------------------------

--Breaking out address into (Address, City, State)

--First the Property Address

Select PropertyAddress
From [Nashville Housing Market].dbo.NashvilleHousing

SELECT 
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 ) as Address
, Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

From ..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From [Nashville Housing Market].dbo.NashvilleHousing



-- Now the Owner Address


Select OwnerAddress
From ..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) as 'Street Address',
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) as 'City',
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) as 'State'
From ..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select *
FROM [Nashville Housing Market].dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------

--Changing Y and N to Yes and No in the Sold as Vacant field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Nashville Housing Market].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From [Nashville Housing Market].dbo.NashvilleHousing

Update NashvilleHousing
Set SoldASVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End




-------------------------------------------------------------------------------------------

--Remove Duplicate entries

With RowNumCTE AS (
Select *,
	Row_Number() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER By
					UniqueID
					)row_num

From [Nashville Housing Market].dbo.NashvilleHousing
--Order By ParcelID

)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress



---------------------------------------------------------------------------------------

--Deleting Unused or Irrelevant Columns



Select * 
From [Nashville Housing Market].dbo.NashvilleHousing

Alter Table [Nashville Housing Market].dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
