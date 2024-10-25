CLASS zsendmail DEFINITION

  PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.
        CLASS-METHODS send_email
            importing lt_email  type string
                    lt_numdoc type string
                    lt_client type string
                    lt_tenant type string
             returning value(rv_result) type string.


         CLASS-METHODS get_instance
              RETURNING
                VALUE(ro_instance) TYPE REF TO zsendmail.


    PRIVATE SECTION.
         CLASS-DATA mo_instance TYPE REF TO zsendmail.
            DATA mv_bp TYPE string.


ENDCLASS.



CLASS ZSENDMAIL IMPLEMENTATION.


  METHOD get_instance.
    IF mo_instance IS NOT BOUND.
      mo_instance = NEW zsendmail( ).
    ENDIF.
    ro_instance = mo_instance.
  ENDMETHOD.


  METHOD send_email.

        data x_body   type String.
        concatenate  'This is a test for sales doc='  lt_numdoc  ' for the client:'  lt_client into x_body.

**        DATA lo_j1bnfe_print  TYPE REF TO cl_j1bnfe_danfe_print.
**        "Initialize Template Store Client
**        data(lo_storex) = NEW zlcl_abap( iv_user = 'JAGDISHP'
**                              it_type = 'Dialog' ). "only for demo
**        DATA(lv_name) = lo_storex->get_name( ).
*
*    try.
*        "Initialize Template Store Client
*          data(lo_store) = new ZCL_FP_TMPL_STORE_CLIENT(
*          iv_service_instance_name = 'ZADSTEMPLATESTORE'
*          iv_use_destination_service = abap_false
*                ).
*
*          data(lo_fdp_util) = cl_fp_fdp_services=>get_instance( 'ZJ_1B_NFE_DANFE' ).
*          "Get initial select keys for service
*          data(lt_keys)     = lo_fdp_util->get_keys( ).
*          lt_keys[ name = 'BR_NOTAFISCAL' ]-value = '13'.
*          data(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
*
*          data(ls_template) = lo_store->get_template_by_name(
*                iv_get_binary     = abap_true
*                iv_form_name      = 'ZNOTA_FISCAL' "<= form object in template store
*                iv_template_name  = 'J_1B_NFE_DANFE_Z' "<= template (in form object) that should be used
*              ).
*
*    catch cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util.
*          rv_result = 'erro load Form template'.
*
*
*    endtry.
*
*          data: xapi type string.
*
*
*
*
*
*    try.
*        cl_fp_ads_util=>render_4_pq(
*            exporting
*              iv_locale       = 'en_US'
*              iv_pq_name      = 'DEFAULT' "<= Name of the print queue where result should be stored
*              iv_xml_data     = lv_xml
*              iv_xdp_layout   = ls_template-xdp_template
*              is_options      = value #(
*                trace_level = 4 "Use 0 in production environment
*              )
*            importing
*              ev_trace_string = data(lv_trace)
*              ev_pdl          = data(lv_pdf)
*          ).
*      catch cx_fp_ads_util.
*        "handle exception
*         rv_result = 'erro redering form template'.
*
*    endtry.

        try.
                data(lo_mail) = cl_bcs_mail_message=>create_instance( ).

                data x_email type lo_mail->ty_address.
                data x_sender type lo_mail->ty_address.

                if lt_tenant eq '100'.
                  x_sender = 'do.not.reply@my402168.mail.lab.s4hana.cloud.sap'.
                else.
                  x_sender = 'do.not.reply@my4021684.mail.lab.s4hana.cloud.sap'.
                endif.

                x_email = lt_email.

                lo_mail->set_sender( 'do.not.reply@mymy402168.mail.lab.s4hana.cloud.sap' ).
                lo_mail->add_recipient( x_email ).
                lo_mail->add_recipient( iv_address = 'william.terceiro01@sap.com' iv_copy = cl_bcs_mail_message=>cc ).
                lo_mail->set_subject( 'ABAP Test Mail Envio DANFE teste2' ).
                lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
                  iv_content      = '<h1>Hello</h1><p>This is a test mail.</p>'
                  iv_content_type = 'text/html'
                ) ).
                lo_mail->add_attachment( cl_bcs_mail_textpart=>create_instance(
                  iv_content      = x_body
*                  iv_content      = lv_pdf
*                  iv_content_type = 'application/pdf'
                  iv_content_type = 'text/plain'
                  iv_filename     = 'Text_DANFE_Attachment.txt'
                ) ).
*               lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance(
*                  iv_content = lv_pdf
*                  iv_content_type = 'application/pdf'
*                  iv_filename = 'Danfe_attachement.pdf'
*                 )
*                ).

                lo_mail->send( importing et_status = data(lt_status) ).

                rv_result = 'Send PDF successfuly'.


              catch cx_bcs_mail into data(lx_mail).
                    rv_result = 'erro send email '.

          COMMIT ENTITIES.
        endtry.



    ENDMETHOD.
ENDCLASS.
