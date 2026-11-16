@EndUserText.label: 'Task Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define root view entity ZC_TASKDEMO
  provider contract transactional_query
  as projection on ZI_TASKDEMO
{
  key TaskId,
      Title,
      Status,
      CreatedAt
}
