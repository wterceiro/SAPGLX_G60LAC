CLASS z_new_job_class_ec DEFINITION
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

CLASS z_new_job_class_ec IMPLEMENTATION.

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


*    try.
        DATA(l_log) = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object =
                 'ZAPP_LOG' subobject = 'ZSUBOBJECT1' ) ).
        data x_body   type String.


        DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
        lv_cid TYPE abp_behv_cid.


        TRY.
            lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        CATCH cx_uuid_error INTO DATA(l_ref).
                 DATA(l_free_texinf0) = cl_bali_free_text_setter=>create( severity =
                            if_bali_constants=>c_severity_information
                            text = 'Erro UUID' ).

                l_log->add_item( item = l_free_texinf0 ).

        ENDTRY.

        DATA(l_free_texinf1) = cl_bali_free_text_setter=>create( severity =
                            if_bali_constants=>c_severity_information
                            text = '*** INit Job Ccode= ' && s_Burks && ' Costcenter=' && s_kostl && ' GlAcctF=' && s_glfrom && ' GlAccTot=' && s_glto && ' fun area=' && s_fkber ).

        l_log->add_item( item = l_free_texinf1 ).

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

*        ENDSELECT.

        data docref type I_Journalentryitem-accountingdocument.


        LOOP AT itab INTO DATA(row_a).


                  select single accountingdocument
                            from I_Journalentry where companycode = @row_a-CompanyCode and Documentreferenceid = @row_a-AccountingDocument
                            into @docref.


                 if  docref is initial.


                        data valdebito type I_Journalentryitem-AmountInCompanyCodeCurrency.

                        valdebito = row_a-AmountInCompanyCodeCurrency * -1.

                        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
                        <je_deep>-%cid = lv_cid.
                        <je_deep>-%param = VALUE #(
                        companycode = s_Burks " Success
                        documentreferenceid = row_a-AccountingDocument
                        createdbyuser = 'TESTER'
                        businesstransactiontype = row_a-BusinessTransactionType
                        accountingdocumenttype = 'SA'
                        documentdate = sy-datlo
                        postingdate = sy-datlo
                        accountingdocumentheadertext = 'Test_JOB_Reclassifica Desp'

                        _glitems = VALUE #(
                        ( glaccountlineitem = |001|  WBSELEMENT = row_a-WBSElement taxcode = 'LI'  glaccount = s_glfrom
                                TaxItemAcctgDocItemRef = '001' TaxJurisdiction = 'SP'  DocumentItemText = 'Item 1 Cre Exp'
                                _currencyamount = VALUE #( ( currencyrole = '00' journalentryitemamount = row_a-AmountInCompanyCodeCurrency
                                taxbaseamount = row_a-AmountInCompanyCodeCurrency   currency =  'BRL' ) ) )

                        ( glaccountlineitem = |002|   glaccount = s_glto WBSELEMENT = row_a-WBSElement  taxcode = 'LI'
                                TaxItemAcctgDocItemRef = '002' TaxJurisdiction = 'SP' DocumentItemText = 'Item 2 Deb Cost'
                         _currencyamount = VALUE #( ( currencyrole = '00' journalentryitemamount = valdebito
                                taxbaseamount = valdebito   currency = 'BRL' ) ) )
                                                )
                                        ).

                        MODIFY ENTITIES OF i_journalentrytp
                        ENTITY journalentry
                        EXECUTE post FROM lt_je_deep
                        FAILED DATA(ls_failed_deep)
                        REPORTED DATA(ls_reported_deep)
                        MAPPED DATA(ls_mapped_deep).


                        IF ls_failed_deep IS NOT INITIAL.

                            LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
                                 DATA(lv_result) = <ls_reported_deep>-%msg->if_message~get_text( ).
                                  DATA(l_failed) = cl_bali_free_text_setter=>create( severity =
                                    if_bali_constants=>c_severity_information
                                    text = '*** Erro Failed Deep ' ).
                                  l_log->add_item( item = l_failed ).

                            ENDLOOP.
                        ELSE.
*                *********************************************************************            COMMIT ENTITIES BEGIN
                            COMMIT ENTITIES RESPONSE OF i_journalentrytp
                            FAILED DATA(lt_commit_failed)
                            REPORTED DATA(lt_commit_reported).
*                            COMMIT ENTITIES END.

                            if lt_commit_failed is not initial.
                                  DATA(l_erro_commit) = cl_bali_free_text_setter=>create( severity =
                                    if_bali_constants=>c_severity_information
                                    text = '*** Erro Commit ' ).
                                  l_log->add_item( item = l_erro_commit ).

                            else.
                            LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep2>).
                                 DATA(lv_result2) = <ls_reported_deep2>-%msg->if_message~get_text( ).
                                  DATA(l_PostOk) = cl_bali_free_text_setter=>create( severity =
                                    if_bali_constants=>c_severity_information
                                    text = '*** Post Reclassification Ok ' ).
                                  l_log->add_item( item = l_PostOk ).
                            ENDLOOP.
                            endif.


                        ENDIF.

                  endif.


        ENDLOOP.


        DATA(l_free_end) = cl_bali_free_text_setter=>create( severity =
                            if_bali_constants=>c_severity_information
                            text = '*** Fim Job Ccode= ' && s_Burks && ' Costcenter=' && s_kostl ).

        l_log->add_item( item = l_free_end ).



        cl_bali_log_db=>get_instance( )->save_log( log = l_log assign_to_current_appl_job = abap_true ).
        COMMIT WORK.




  ENDMETHOD.


ENDCLASS.
