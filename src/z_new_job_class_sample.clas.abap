CLASS z_new_job_class_sample DEFINITION
  PUBLIC
  INHERITING FROM  cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS z_new_job_class_sample IMPLEMENTATION.

  METHOD if_apj_dt_exec_object~get_parameters.

    "# Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'SO_BURKS'   kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 4 param_text = 'CompanyCode' changeable_ind = abap_true )
      ( selname = 'SO_KOSTL'   kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'Cost Center' changeable_ind = abap_true )
      ( selname = 'SO_FKBER'   kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 4 param_text = 'Functional Aera' changeable_ind = abap_true )
      ( selname = 'SO_GLFR'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 16 param_text = 'GL Acct From' changeable_ind = abap_true )
      ( selname = 'SO_GLTO'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 16 param_text = 'GL Acct To' changeable_ind = abap_true )
       ).
    "# Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'SO_BURKS'   kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '1411' )
      ( selname = 'SO_KOSTL'   kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '0014111101' )
      ( selname = 'SO_FKBER'   kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = 'YB25' )
      ( selname = 'SO_GLFR'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '0061005000' )
      ( selname = 'SO_GLTO'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '0065008420' )
      ).


  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    data s_Burks  TYPE c length 4.
    DATA s_kostl  TYPE c LENGTH 10.
    DATA s_fkber  TYPE c LENGTH 10.
    data s_glfrom type c length 10.
    data s_glto   type c length 10.


    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'SO_BURKS'.
          s_Burks = ls_parameter-low.
        WHEN 'SO_KOSTL'.
           s_kostl = ls_parameter-low.
        WHEN 'SO_FKBER'.
           s_fkber = ls_parameter-low.
        WHEN 'SO_GLFR'.
           s_glfrom = ls_parameter-low.
        WHEN 'SO_GLTO'.
           s_glto = ls_parameter-low.
      ENDCASE.
    ENDLOOP.






    TRY.
        DATA(lo_log) = cl_bali_log=>create( ).
        lo_log->set_header( header = cl_bali_header_setter=>create( object = 'ZAPP_LOG'
                                                                    subobject = 'ZSUBOBJECT1'
                                                                    external_id = 'JobPosting' ) ).


" Free text
        DATA(lo_free) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_warning
                                                  text     = 'Execution Initiated' ).
          lo_log->add_item( item = lo_free ).
          cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).



        DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
        lv_cid TYPE abp_behv_cid.


        TRY.
            lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        CATCH cx_uuid_error INTO DATA(l_ref).
                 DATA(l_free_texinf0) = cl_bali_free_text_setter=>create( severity =
                            if_bali_constants=>c_severity_information
                            text = 'Erro UUID' ).
            DATA(lo_free1) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_warning
                                                   text     = 'Execution Initiated' ).
            lo_log->add_item( item = lo_free1 ).
            cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).

        ENDTRY.

        data docref type I_Journalentryitem-accountingdocument.


        select companycode, glaccount, ledger, fiscalyear, ACCOUNTINGDOCUMENTTYPE,
                BUSINESSTRANSACTIONCATEGORY,
                BUSINESSTRANSACTIONTYPE, REFERENCEDOCUMENTTYPE , accountingdocument, ledgergllineitem, WBSELEMENT ,
                DEBITCREDITCODE,
                AMOUNTINTRANSACTIONCURRENCY, AMOUNTINGLOBALCURRENCY, AmountInCompanyCodeCurrency,
                DEBITAMOUNTINCOCODECRCY, CREDITAMOUNTINCOCODECRCY
                from I_Journalentryitem
                where companycode = @s_Burks and GLACCOUNT = @s_glfrom and WBSELEMENT  > ' ' and CREDITAMOUNTINCOCODECRCY = 0 and FUNCTIONALAREA = @s_fkber
                      and REVERSALREFERENCEDOCUMENT = ' ' and LEDGER = '0L'
                into table @data(itab).

        LOOP AT itab INTO DATA(row_a).


                  select single accountingdocument
                            from I_Journalentry where companycode = @row_a-CompanyCode and Documentreferenceid = @row_a-AccountingDocument
                            into @docref.


                if  docref is initial.


                        data valdebito type I_Journalentryitem-AmountInCompanyCodeCurrency.
*
                         valdebito = row_a-AmountInCompanyCodeCurrency * -1.

                        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
                        <je_deep>-%cid = lv_cid.
                        <je_deep>-%param = VALUE #(
                        companycode = s_Burks " Success
                        documentreferenceid = row_a-AccountingDocument
                        createdbyuser = 'TESTER'
                        accountingdocumenttype = 'SA'
                        documentdate = sy-datlo
                        postingdate = sy-datlo
                        accountingdocumentheadertext = 'Test_JOB_Reclassifica Desp'
*
                        _glitems = VALUE #(
                        ( glaccountlineitem = |001|  WBSELEMENT = row_a-WBSElement taxcode = 'LI'  glaccount = s_glfrom
                                TaxItemAcctgDocItemRef = '001' TaxJurisdiction = 'SP'  DocumentItemText = 'Item 1 Cre Exp'
                                _currencyamount = VALUE #( ( currencyrole = '00' journalentryitemamount = valdebito
                                taxbaseamount = valdebito   currency =  'BRL' ) ) )

                        ( glaccountlineitem = |002|   glaccount = s_glto WBSELEMENT = row_a-WBSElement  taxcode = 'LI'
                                TaxItemAcctgDocItemRef = '002' TaxJurisdiction = 'SP' DocumentItemText = 'Item 2 Deb Cost'
                         _currencyamount = VALUE #( ( currencyrole = '00' journalentryitemamount = row_a-AmountInCompanyCodeCurrency
                                taxbaseamount = row_a-AmountInCompanyCodeCurrency   currency = 'BRL' ) ) )
                                                )
                                        ).

                        MODIFY ENTITIES OF i_journalentrytp
                        ENTITY journalentry
                        EXECUTE post FROM lt_je_deep
                        FAILED DATA(ls_failed_deep)
                        REPORTED DATA(ls_reported_deep)
                        MAPPED DATA(ls_mapped_deep).
*
                        IF ls_failed_deep IS NOT INITIAL.

                            LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
                                 DATA(lv_result) = <ls_reported_deep>-%msg->if_message~get_text( ).
                                 DATA(lo_free2) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_error
                                                  text     = 'Execution Failed' && lv_result ).
                                 lo_log->add_item( item = lo_free2 ).
                                 cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).
                            ENDLOOP.
                        ELSE.
                            COMMIT ENTITIES RESPONSE OF i_journalentrytp
                            FAILED DATA(lt_commit_failed)
                            REPORTED DATA(lt_commit_reported).
*
                            if lt_commit_failed is not initial.
                                 DATA(lo_free3) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_error
                                                  text     = 'Execution commit Failed' ).
                                 lo_log->add_item( item = lo_free3 ).
                                 cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).

                            else.
                                LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep2>).
                                     DATA(lv_result2) = <ls_reported_deep2>-%msg->if_message~get_text( ).
                                     DATA(lo_free4) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_information
                                                  text     = 'Execution Initiated= ' && lv_result2 ).
                                     lo_log->add_item( item = lo_free4 ).
                                     cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).
                                ENDLOOP.
                            endif.
*
                        ENDIF.

                        DATA(lo_free5) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_information
                                                  text     = 'Execution Termined' ).
                        lo_log->add_item( item = lo_free5 ).
                        cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).

                  endif.

        ENDLOOP.

        DATA(lo_free6) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_Information
                                                  text  = '*** INit Job Ccode= ' && s_Burks && ' Costcenter=' && s_kostl && ' GlAcctF=' && s_glfrom && ' GlAccTot=' && s_glto && ' fun area=' && s_fkber ).
        lo_log->add_item( item = lo_free6 ).
        cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).

          COMMIT ENTITIES.

      CATCH cx_bali_runtime INTO DATA(lx_bali_runtime).
        DATA(lv_bali_runtime) = lx_bali_runtime->get_text(  ).
    ENDTRY.


   COMMIT WORK.




  ENDMETHOD.


ENDCLASS.
