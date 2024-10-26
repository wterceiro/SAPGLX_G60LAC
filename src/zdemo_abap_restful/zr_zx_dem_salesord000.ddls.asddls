@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_ZX_DEM_SALESORD000
  as select from ZZX_DEM_SALESORD
{
  key id as Id,
  firstname as Firstname,
  lastname as Lastname,
  age as Age,
  role as Role,
  companycode as Companycode,
  cuky_field as CukyField,
  @Semantics.amount.currencyCode: 'CukyField'
  valvenda as Valvenda,
  unit_field as UnitField,
  @Semantics.quantity.unitOfMeasure: 'UnitField'
  quantity as Quantity,
  bpnumber as Bpnumber,
  producto as Producto,
  salesorg as Salesorg,
  active as Active,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
