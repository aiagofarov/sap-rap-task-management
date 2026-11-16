CLASS lhc_Task DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setCreatedAt FOR DETERMINE ON MODIFY
       keys FOR Task~setCreatedAt.

    METHODS validateTitle FOR VALIDATE ON SAVE
       keys FOR Task~validateTitle.
    METHODS completeTask FOR MODIFY
       keys FOR ACTION Task~completeTask RESULT result.

ENDCLASS.

CLASS lhc_Task IMPLEMENTATION.

  METHOD setCreatedAt.

    MODIFY ENTITIES OF zi_taskdemo IN LOCAL MODE
      ENTITY Task
      UPDATE FIELDS ( CreatedAt )
      WITH VALUE #(
        FOR key IN keys
        (
          %tky      = key-%tky
          CreatedAt = utclong_current( )
        )
      )
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD validateTitle.

    READ ENTITIES OF zi_taskdemo IN LOCAL MODE
      ENTITY Task
      FIELDS ( Title )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_tasks).

    LOOP AT lt_tasks INTO DATA(ls_task).

      APPEND VALUE #(
        %tky        = ls_task-%tky
        %state_area = 'VALIDATE_TITLE'
      ) TO reported-task.

      IF ls_task-Title IS INITIAL.

        APPEND VALUE #(
          %tky = ls_task-%tky
        ) TO failed-task.

        APPEND VALUE #(
          %tky        = ls_task-%tky
          %state_area = 'VALIDATE_TITLE'
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Task title cannot be empty'
          )
          %element-Title = if_abap_behv=>mk-on
        ) TO reported-task.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD completeTask.

    "Read actual state
    READ ENTITIES OF zi_taskdemo IN LOCAL MODE
      ENTITY Task
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_tasks).

    "Check
    LOOP AT lt_tasks INTO DATA(ls_task).

      IF ls_task-Status <> 'OPEN'.

        APPEND VALUE #(
          %tky = ls_task-%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-task.

        APPEND VALUE #(
          %tky = ls_task-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Only OPEN tasks can be completed'
          )
        ) TO reported-task.

      ENDIF.

    ENDLOOP.

    "Set status
    MODIFY ENTITIES OF zi_taskdemo IN LOCAL MODE
      ENTITY Task
      UPDATE FIELDS ( Status )
      WITH VALUE #(
        FOR task IN lt_tasks
        WHERE ( Status = 'OPEN' )
        (
          %tky   = task-%tky
          Status = 'DONE'
        )
      )
    FAILED DATA(lt_failed_update)
    REPORTED DATA(lt_reported_update).

    APPEND LINES OF lt_failed_update-task TO failed-task.
    APPEND LINES OF lt_reported_update-task TO reported-task.

    "Read
    READ ENTITIES OF zi_taskdemo IN LOCAL MODE
      ENTITY Task
      ALL FIELDS
      WITH VALUE #(
        FOR task IN lt_tasks
        WHERE ( Status = 'OPEN' )
        (
          %tky = task-%tky
        )
      )
      RESULT DATA(lt_updated_tasks).

    "Return result
    result = VALUE #(
      FOR task IN lt_updated_tasks
      (
        %tky   = task-%tky
        %param = task
      )
    ).

  ENDMETHOD.

ENDCLASS.
