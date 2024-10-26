@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_ZX_DEM_SALESORD000
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_ZX_DEM_SALESORD000
{
  key Id,
  Firstname,
  Lastname,
  Age,
  Role,
  Companycode,
  @Semantics.currencyCode: true
  CukyField,
  Valvenda,
  @Semantics.unitOfMeasure: true
  UnitField,
  Quantity,
  Bpnumber,
  Producto,
  Salesorg,
  Active,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
