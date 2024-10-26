@EndUserText.label: 'View Consumption  for Interface View'
@Metadata.allowExtensions: true

@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_DEMO_5551
  provider contract transactional_query
as projection on ZI_DEMO_5551 as UXTeam
{
@EndUserText.label: 'Id'
key Id,
@EndUserText.label: 'First Name'
@Search.defaultSearchElement: true
Firstname,
@EndUserText.label: 'Last Name'
@Search.defaultSearchElement: true
Lastname,
@EndUserText.label: 'Age'
Age,
@Search.defaultSearchElement: true
@EndUserText.label: 'Role'
Role,
@EndUserText.label: 'Salary'
Salary,
@EndUserText.label: 'Active'
Active,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
}
