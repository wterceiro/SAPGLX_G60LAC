@EndUserText.label: 'Demo for C0 released API'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

@AbapCatalog.extensibility: {
  extensible: true,
  elementSuffix: 'YY1',
  allowNewDatasources: false,
  dataSources: ['Persistence'],
  quota: {
    maximumFields: 250,
    maximumBytes: 2500
  }
}
define view entity ZDV_DATA_DEMO
  as select from zzx_demo_ctr as Persistence
{
  key product_id
}
