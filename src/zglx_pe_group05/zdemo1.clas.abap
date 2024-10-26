CLASS zdemo1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

 PUBLIC SECTION.
Interfaces if_oo_adt_classrun.
PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS ZDEMO1 IMPLEMENTATION.


method if_oo_adt_classrun~main.
out->write( 'Hello Cloud' ).
Select from I_PROduct fields product into table @data(lt_mara).
out->write( lt_mara ).
Endmethod.
ENDCLASS.
