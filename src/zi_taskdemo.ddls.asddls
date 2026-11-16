@EndUserText.label: 'Task Interface View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

define root view entity ZI_TASKDEMO
  as select from ztaskdemo
{
  key task_id    as TaskId,
      title      as Title,
      status     as Status,
      created_at as CreatedAt
}
