CLASS z_tax_brl_payloadv3 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_gslog_ext_tax_calc_payload .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z_TAX_BRL_PAYLOADV3 IMPLEMENTATION.


  METHOD if_gslog_ext_tax_calc_payload~extend_payload.



   if pricing_header-kappl = 'V' and  pricing_header-auart = 'OR'.
             payload-gross_or_net = 'g'.
   endif.

*   if pricing_header-kappl = 'V' and ( pricing_header-auart = 'ROB' or
*                             ( pricing_header-auart_sd = 'ROB' and pricing_header-fkart = 'CBRE' ) ).
*      LOOP AT payload-_items ASSIGNING FIELD-SYMBOL(<fs_item>).
*        LOOP AT <fs_item>-additional_item_information ASSIGNING FIELD-SYMBOL(<fs_info>).
*
*          if <fs_info>-type = 'referenceID'.
*
*                select  single EXTTAXCALCULATIONTRACEUUID from I_ExtTaxCalculationTrace with privileged access where
*                       conditionapplication = 'V' and EXTTAXCALCDOCUMENTCATEGORY = 'C' and EXTTAXCALCDOCUMENTNUMBER = @pricing_header-inco2
*                         into @DATA(taxengineguid).
*
*            <fs_info>-information = taxengineguid.
*          endif.
*        ENDLOOP.
*      ENDLOOP.
*   endif.

*      LOOP AT payload-_items ASSIGNING FIELD-SYMBOL(<fs_item>).
*        LOOP AT <fs_item>-additional_item_information ASSIGNING FIELD-SYMBOL(<fs_info>).
*
*          CHECK <fs_info>-type = 'CPRB'.
*          <fs_info>-information = 'Y'.
*
*        ENDLOOP.
*      ENDLOOP.



  ENDMETHOD.
ENDCLASS.
