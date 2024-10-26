CLASS lhc_uxteam DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR uxteam RESULT result.

    METHODS setactive FOR MODIFY
      IMPORTING keys FOR ACTION uxteam~setactive RESULT result.

    METHODS changesalary FOR DETERMINE ON SAVE
      IMPORTING keys FOR uxteam~changesalary.

    METHODS validateage FOR VALIDATE ON SAVE
      IMPORTING keys FOR uxteam~validateage.

ENDCLASS.

CLASS lhc_uxteam IMPLEMENTATION.

  METHOD get_instance_features.
  " Read the active flag of the existing members
    READ ENTITIES OF zi_demo_5551 IN LOCAL MODE
        ENTITY UXTeam
             FIELDS ( Active ) WITH CORRESPONDING #( keys )
             RESULT DATA(members)
        FAILED failed.
    result =
        VALUE #(
            FOR member IN members
                LET status = COND #( WHEN member-Active = abap_true
                THEN if_abap_behv=>fc-o-disabled
                ELSE if_abap_behv=>fc-o-enabled )
            IN
                ( %tky = member-%tky
                 %action-setActive = status
                 ) ).
  ENDMETHOD.

  METHOD setactive.

    " Do background check
    " Check references
    " Onboard member
    MODIFY ENTITIES OF zi_demo_5551 IN LOCAL MODE
          ENTITY UXTeam
             UPDATE
             FIELDS ( Active )
                 WITH VALUE #( FOR key IN keys
                    ( %tky = key-%tky
                    Active = abap_true
                    ) )
            FAILED failed
    REPORTED reported.
    " Fill the response table
    READ ENTITIES OF zi_demo_5551 IN LOCAL MODE
            ENTITY UXTeam
            ALL FIELDS WITH CORRESPONDING #( keys )
             RESULT DATA(members).
    result = VALUE #( FOR member IN members
    ( %tky = member-%tky
    %param = member ) ).
  ENDMETHOD.

  METHOD changesalary.

          " Read relevant UXTeam instance data
        READ ENTITIES OF zi_demo_5551 IN LOCAL MODE
            ENTITY UXTeam
                FIELDS ( Role ) WITH CORRESPONDING #( keys )
                RESULT DATA(members).
        LOOP AT members INTO DATA(member).
            IF member-Role = 'UX Developer'.
                " Change salary to hard coded value
                    MODIFY ENTITIES OF zi_demo_5551 IN LOCAL MODE
                            ENTITY UXTeam
                            UPDATE
                            FIELDS ( Salary )
                            WITH VALUE #(
                                ( %tky = member-%tky
                                     Salary = 7000
                                ) ).
            ENDIF.

             IF member-Role = 'UX Lead'.
                             " Change salary to hard coded value
                   MODIFY ENTITIES OF zi_demo_5551 IN LOCAL MODE
                           ENTITY UXTeam
                            UPDATE
                             FIELDS ( Salary )
                                WITH VALUE #(
                                ( %tky = member-%tky
                                Salary = 9000
                                ) ).
            ENDIF.
        ENDLOOP.

  ENDMETHOD.

  METHOD validateage.

            READ ENTITIES OF zi_demo_5551 IN LOCAL MODE
                    ENTITY UXTeam
                    FIELDS ( Age ) WITH CORRESPONDING #( keys )
                    RESULT DATA(members).

            LOOP AT members INTO DATA(member).
                    IF member-Age < 21.
                        APPEND VALUE #( %tky = member-%tky ) TO failed-uxteam.
                    ENDIF.
            ENDLOOP.


  ENDMETHOD.

ENDCLASS.
