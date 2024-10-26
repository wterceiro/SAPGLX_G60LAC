@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'View Inteface for table ZRAP_DEMO_5551'
define root view entity  ZI_DEMO_5551
 as select from zrap_demo_5551 
{
    key id as Id,
    firstname as Firstname,
    lastname as Lastname,
    age as Age,
    role as Role,
    salary as Salary,
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
