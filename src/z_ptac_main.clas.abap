CLASS z_ptac_main DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_oo_adt_classrun.
ENDCLASS.



CLASS z_ptac_main IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    out->write( 'Hello, world' ).

    data s_Burks  TYPE c length 4.
    DATA s_kostl  TYPE c LENGTH 10.
    DATA s_fkber  TYPE c LENGTH 10.
    data s_glfrom type c length 10.
    data s_glto   type c length 10.


    s_Burks = '1410'.
    s_kostl = '14101001'.
    s_fkber = 'YB25'.
    s_glfrom = '0061005000'.
    s_glto = '0065008420'.


        DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
        lv_cid TYPE abp_behv_cid.
        TRY.
            lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        CATCH cx_uuid_error INTO DATA(l_ref).
                 DATA(l_free_texinf0) = cl_bali_free_text_setter=>create( severity =
                            if_bali_constants=>c_severity_information
                            text = 'Erro UUID' ).



        ENDTRY.

         out->write( '*** INit Job Ccode= ' && s_Burks && ' Costcenter=' && s_kostl && ' lv_cid=' && lv_cid ).

           select companycode, glaccount, ledger, fiscalyear, ACCOUNTINGDOCUMENTTYPE,
                BUSINESSTRANSACTIONCATEGORY,
                BUSINESSTRANSACTIONTYPE, REFERENCEDOCUMENTTYPE , accountingdocument, ledgergllineitem, WBSELEMENT ,
                DEBITCREDITCODE,
                AMOUNTINTRANSACTIONCURRENCY, AMOUNTINGLOBALCURRENCY, AmountInCompanyCodeCurrency,
                DEBITAMOUNTINCOCODECRCY, CREDITAMOUNTINCOCODECRCY
                from I_Journalentryitem
                where companycode = @s_Burks and GLACCOUNT = @s_glfrom and WBSELEMENT  > ' ' and CREDITAMOUNTINCOCODECRCY = 0 and FUNCTIONALAREA = @s_fkber
                      and REVERSALREFERENCEDOCUMENT = ' '
                into table @data(itab).

*        ENDSELECT.

        data docref type I_Journalentryitem-accountingdocument.


        LOOP AT itab INTO DATA(row_a).


                  select single accountingdocument
                            from I_Journalentry where companycode = @row_a-CompanyCode and Documentreferenceid = @row_a-AccountingDocument
                            into @docref.

                        out->write( 'antes do loop=' && docref ).

                 if  docref is initial.
                        out->write( 'dentro do loop' ).
                        out->write( itab ).

*                        data valdebito type I_Journalentryitem-AmountInCompanyCodeCurrency.
*
*                        valdebito = row_a-AmountInCompanyCodeCurrency * -1.
*
*                        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
*                        <je_deep>-%cid = lv_cid.
*                        <je_deep>-%param = VALUE #(
*                        companycode = s_Burks " Success
*                        documentreferenceid = row_a-AccountingDocument
*                        createdbyuser = 'TESTER'
*                        businesstransactiontype = row_a-BusinessTransactionType
*                        accountingdocumenttype = 'SA'
*                        documentdate = sy-datlo
*                        postingdate = sy-datlo
*                        accountingdocumentheadertext = 'Test_JOB_Reclassifica Desp'
*
*                        _glitems = VALUE #(
*                        ( glaccountlineitem = |001|  WBSELEMENT = row_a-WBSElement taxcode = 'LI'  glaccount = s_glfrom
*                                TaxItemAcctgDocItemRef = '001' TaxJurisdiction = 'SP'  DocumentItemText = 'Item 1 Cre Exp'
*                                _currencyamount = VALUE #( ( currencyrole = '00' journalentryitemamount = row_a-AmountInCompanyCodeCurrency
*                                taxbaseamount = row_a-AmountInCompanyCodeCurrency   currency =  'BRL' ) ) )
*
*                        ( glaccountlineitem = |002|   glaccount = s_glto WBSELEMENT = row_a-WBSElement  taxcode = 'LI'
*                                TaxItemAcctgDocItemRef = '002' TaxJurisdiction = 'SP' DocumentItemText = 'Item 2 Deb Cost'
*                         _currencyamount = VALUE #( ( currencyrole = '00' journalentryitemamount = valdebito
*                                taxbaseamount = valdebito   currency = 'BRL' ) ) )
*                                                )
*                                        ).
*
*                        MODIFY ENTITIES OF i_journalentrytp
*                        ENTITY journalentry
*                        EXECUTE post FROM lt_je_deep
*                        FAILED DATA(ls_failed_deep)
*                        REPORTED DATA(ls_reported_deep)
*                        MAPPED DATA(ls_mapped_deep).
*
*
*                        IF ls_failed_deep IS NOT INITIAL.
*
*                            LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
*                                 DATA(lv_result) = <ls_reported_deep>-%msg->if_message~get_text( ).
*                                 out->write( lv_result ).
*                            ENDLOOP.
*                        ELSE.
**                *********************************************************************            COMMIT ENTITIES BEGIN
*                            COMMIT ENTITIES RESPONSE OF i_journalentrytp
*                            FAILED DATA(lt_commit_failed)
*                            REPORTED DATA(lt_commit_reported).
**                            COMMIT ENTITIES END.
*
*                            if lt_commit_failed is not initial.
*                                            out->write( 'Job Post failed in commit' ).
*
*                            else.
*                            LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep2>).
*                                 DATA(lv_result2) = <ls_reported_deep2>-%msg->if_message~get_text( ).
*                                 out->write( lv_result2 ).
*                            ENDLOOP.
*                            endif.
*
*
*                        ENDIF.
*
                 endif.


        ENDLOOP.




  ENDMETHOD.
ENDCLASS.
