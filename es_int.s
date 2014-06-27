*------------Autor-------------*
*Alberto Martin Mazaira s100231*



	ORG $0
	DC.L $8000 *Stack pointer
	DC.L    PRPRINT




*Reserva de memoria
	ORG $408

BuffSA: DS.B 2000
EndSA: DS.B 2
PuntSAE: DS.B 2
PuntSAL: DS.B 2


*BuffSA: DC.B $61,$62,$d,$63,$64,$d,$65,$66,$31,$32,$d,$33


BuffPA: DS.B 2000
EndPA: DS.B 2
PuntPAE: DS.B 2
PuntPAL: DS.B 2
BEscPA: DS.B 2

BuffSB: DS.B 2000
EndSB: DS.B 2
PuntSBE: DS.B 2
PuntSBL: DS.B 2
BEscSB: DS.B 2


BuffPB: DS.B 2000
EndPB: DS.B 2
PuntPBE: DS.B 2
PuntPBL: DS.B 2
BEscPB: DS.B 2



IMRCopia: DS.B 2






****INIT****

INIT:
	MOVE.B #%00000011,$effc01 	*8bits por caracter en A y Receiver Ready MRA
	MOVE.B #%00000011,$effc11 	*8bits por caracter en B y Receiver Ready MRB
	MOVE.B #%00000000,$effc01 	*Eco desactivado en A
	MOVE.B #%00000000,$effc11 	*Eco desactivado en B
	MOVE.B #%11001100,$effc03 	*Vrecep=Vtrans=38400 bps en A
	MOVE.B #%11001100,$effc15 	*Vrecep=Vtrans=38400 bps en B
	MOVE.B #%00000101,$effc05 	*Full Duplex A
	MOVE.B #%00000101,$effc15 	*Full Duplex B
	MOVE.B #$40,$effc19 		*Vector de interrupción 40
	MOVE.B #%00100010,$effc0B 	*Habilitar las interrupciones en IMR
	MOVE.B #%00100010,IMRCopia

	LEA RTI,A1
	MOVE.L #$100,A2
	MOVE.L A1,(A2)
	
	LEA BuffSA,A1
	MOVE.W A1,PuntSAE
	MOVE.W A1,PuntSAL
	LEA EndSA,A1
	MOVE.W A1,EndSA
	
	
	LEA BuffPA,A1
	MOVE.W A1,PuntPAE
	MOVE.W A1,PuntPAL
	LEA EndPA,A1
	MOVE.W A1,EndPA
		
	
	LEA BuffSB,A1
	MOVE.L A1,PuntSBE
	MOVE.L A1,PuntSBL
	LEA EndSB,A1
	MOVE.L A1,EndSB

	LEA BuffPB,A1
	MOVE.L A1,PuntPBE
	MOVE.L A1,PuntPBL
	LEA EndPB,A1
	MOVE.L A1,EndPB

	RTS

*****************

****LEECAR*******
*REGISTROS:D0,A2,A3

LEECAR:
	LINK A6,#0
	CMP.W #0,D0				*Switch 
	BEQ LEECARSA
	CMP.W #1,D0
	BEQ LEECARSB
	CMP.W #2,D0
	BEQ LEECARPA 
	CMP.W #3,D0
	BEQ LEECARPB
	MOVE.L #$FFFFFFFF,D0
	BRA FIN 

LEECARSA:
	MOVE.W PuntSAE,A2
	MOVE.W PuntSAL,A3
	LEA BuffSA,A4
	MOVE.W EndSA,A5
	CMP.W A2,A3
	BEQ EMPTY
	CMP.W A3,A5
	BEQ LRESETSA
LCONT_SA:	MOVE.B (A3)+,D0
	MOVE.W A3,PuntSAL
	BRA FIN

LEECARSB:
	MOVE.W PuntSBE,A2
	MOVE.W PuntSBL,A3
	LEA BuffSB,A4
	MOVE.W EndSB,A5
	CMP.W A2,A3
	BEQ EMPTY
	CMP.W A3,A5
	BEQ LRESETSB
LCONT_SB:	MOVE.B (A3)+,D0
	MOVE.W A3,PuntSBL
	BRA FIN

LEECARPA:
	MOVE.W PuntPAE,A2
	MOVE.W PuntPAL,A3
	MOVE.W EndPA,A5
	LEA BuffPA,A4
	CMP.W A2,A3
	BEQ EMPTY
	CMP.W A3,A5
	BEQ LRESETPA
LCONT_PA:	MOVE.B (A3)+,D0
	MOVE.W A3,PuntPAL
	BRA FIN

LEECARPB:
	MOVE.W PuntPBE,A2
	MOVE.W PuntPBL,A3
	LEA BuffPB,A4
	MOVE.W EndPB,A5
	CMP.W A2,A3
	BEQ EMPTY
	CMP.W A3,A5
	BEQ LRESETPB
LCONT_PB:	MOVE.B (A3)+,D0
	MOVE.W A3,PuntPBL
	BRA FIN
EMPTY:
	MOVE.L #$FFFFFFFF,D0
	BRA FIN
LRESETSA:
	MOVE.W A4,A0
	BRA LCONT_SA
LRESETSB:
	MOVE.W A4,A0
	BRA LCONT_SB
LRESETPA:
	MOVE.W A4,A0
	BRA LCONT_PA
LRESETPB:
	MOVE.W A4,A0
	BRA LCONT_PB




**** FIN LEECAR*******

*****  ESCCAR   *******

ESCCAR:
	LINK A6,#0
	CMP.W #0,D0				*Switch 
	BEQ ESCCARSA
	CMP.W #1,D0
	BEQ ESCCARSB
	CMP.W #2,D0
	BEQ ESCCARPA 
	CMP.W #3,D0
	BEQ ESCCARPB
	MOVE.L #$FFFFFFFF,D0
	BRA FIN 

ESCCARSA:
	MOVE.W PuntSAE,A0
	MOVE.W EndSA,A1
	MOVE.W PuntSAL,A3
	LEA BuffSA,A4
	ADD.W #1,A0
	CMP.W A0,A3
	BEQ FULL
	SUB.W #1,A0
	CMP.W A0,A1
	BEQ RESETSA
CONT_SA:	MOVE.B D1,(A0)+
	MOVE.W A0,PuntSAE
	CLR.W D0
	BRA FIN

ESCCARSB:
	MOVE.W PuntSBE,A0
	MOVE.W EndSB,A1
	MOVE.W PuntSBL,A3
	LEA BuffSB,A4
	ADD.W #1,A0
	CMP.W A0,A3
	BEQ FULL
	SUB.W #1,A0
	CMP.W A0,A1
	BEQ RESETSB
CONT_SB:	MOVE.B D1,(A0)+
	MOVE.W A0,PuntSBE
	CLR.W D0
	BRA FIN

ESCCARPA:
	MOVE.W PuntPAE,A0
	MOVE.W EndPA,A1
	MOVE.W PuntPAL,A3
	LEA BuffPA,A4
	ADD.W #1,A0
	CMP.W A0,A3
	BEQ FULL
	SUB.W #1,A0
	CMP.W A0,A1
	BEQ RESETPA
CONT_PA:	MOVE.B D1,(A0)+
	MOVE.W A0,PuntPAE
	CLR.W D0
	BRA FIN

ESCCARPB:
	MOVE.W PuntPBE,A0
	MOVE.W EndPB,A1
	MOVE.W PuntPBL,A3
	LEA BuffPB,A4
	ADD.W #1,A0
	CMP.W A0,A3
	BEQ FULL
	SUB.W #1,A0
	CMP.W A0,A1
	BEQ RESETPB
CONT_PB:	MOVE.B D1,(A0)+
	MOVE.W A0,PuntPBE
	CLR.W D0
	BRA FIN
FULL:
	MOVE.L #$FFFFFFFF,D0
	BRA FIN
RESETSA:
	MOVE.W A4,A0
	BRA CONT_SA
RESETSB:
	MOVE.W A4,A0
	BRA CONT_SB
RESETPA:
	MOVE.W A4,A0
	BRA CONT_PA
RESETPB:
	MOVE.W A4,A0
	BRA CONT_PB


**** FIN ESCCAR*******

****SCAN*******
*REGISTROS UTILIZADOS: D0,A0,A1

CONTS	DS.W 	2
SCAN:
	LINK A6,#0
	MOVE.L 8(A6),A0 *dir buffer
	MOVE.W 12(A6),D0 *descriptor
	MOVE.W 14(A6),D1 *tamaño
	MOVE.W #$0,CONTS
	MOVE.W CONTS,D2
	CMP.W #0,D1
	BEQ FIN_SCAN
	
BUCLE_SCAN:
	MOVE.W 12(A6),D0 *descriptor
	BSR LEECAR
	CMP.W #$FFFFFFFF,D0
	BEQ FIN_SCAN
	MOVE.B D0,(A0)+
	SUB.W #1,D1
	ADD.W #1,D2
	CMP.W #0,D1
	BEQ FIN_SCAN
	BSR BUCLE_SCAN
FIN_SCAN:
	MOVE.L D2,D0
	BRA FIN


**** FIN SCAN *******


****PRINT*******
CONTP	DS.W 	2

PRINT:
	LINK A6,#0
	MOVE.L 8(A6),A2 *dir buffer
	MOVE.W 12(A6),D0 *descriptor
	MOVE.W 14(A6),D2 *tamaño
	MOVE.W #$0,CONTP
	MOVE.W CONTP,D3
	
BUCLE_PRINT:
	CMP.W #0,D2
	BEQ FIN_PRINT
	MOVE.B (A2)+,D1
	BSR ESCCAR
	CMP.W #$FFFFFFFF,D0
	BEQ FIN_PRINT
	SUB.W #1,D2
	ADD.W #1,D3
	CMP.W #0,D2
	BEQ FIN_PRINT
	BSR BUCLE_PRINT
FIN_PRINT:
	MOVE.L D3,D0

	BRA FIN


**** FIN PRINT*******

*****FIN*****

FIN:
	UNLK A6
	RTS
*** FIN FIN ******


**** RTI *******

RTI:
	MOVE.L D0,-(A7)
	MOVE.L D1,-(A7)
	MOVE.L A0,-(A7)
	MOVE.L A1,-(A7)
	MOVE.L A2,-(A7)
	MOVE.L A3,-(A7)
	MOVE.B IMRCopia,D1

	BTST #0,D1
	BNE TrA
	BTST #1,D1
	BNE RecA
	BTST #4,D1
	BNE TrB
	BTST #5,D1
	BNE RecB
	BRA FIN_RTI
TrA:
	MOVE.L D1,D0
	BRA LEECAR
	MOVE.L D0,$effc07
	BCLR.B    #0,IMRCopia       
    MOVE.B    IMRCopia,$effc0B		
	BRA FIN_RTI		

TrB:
	MOVE.L D1,D0
	BRA LEECAR
	MOVE.L D0,$effc17
	BCLR.B    #4,IMRCopia       
    MOVE.B    IMRCopia,$effc0B		
	BRA FIN_RTI	
RecA:
	MOVE.B $effc07,D1
	MOVE.L #1,D0
	BRA ESCCAR
	BCLR.B    #0,IMRCopia       
    MOVE.B    IMRCopia,$effc0B
	BRA FIN_RTI	
RecB:
	MOVE.B $effc17,D1
	MOVE.L #2,D0
	BRA ESCCAR
	BCLR.B    #4,IMRCopia       
    MOVE.B    IMRCopia,$effc0B
	BRA FIN_RTI	
	
	
FIN_RTI:
	MOVE.L (A7)+,A3
	MOVE.L (A7)+,A2
	MOVE.L (A7)+,A1
	MOVE.L (A7)+,A0
	MOVE.L (A7)+,D1
	MOVE.L (A7)+,D0
	RTE





		*** Prueba básica:




PRESC:
	BSR INIT
	MOVE.W #0,D0
	MOVE.W #$64,D1
	BSR ESCCAR
	MOVE.W #0,D0
	MOVE.W #$55,D1
	BSR ESCCAR
	MOVE.W #0,D0
	MOVE.W #$18,D1
	BSR ESCCAR
	BREAK

PRLEE:
	BSR INIT
	MOVE.W #0,D0
	LEA BuffSA,A1
	MOVE.W PuntSAE,A2
	MOVE.B #$11,(A2)+
	MOVE.B #$22,(A2)+
	MOVE.B #$33,(A2)+
	MOVE.B #$44,(A2)
	MOVE.W A2,PuntSAE
	BSR LEECAR
	MOVE.W #0,D0
	BSR LEECAR
	MOVE.W #0,D0
	BSR LEECAR
	BREAK

PRSCAN:
	BSR INIT
	MOVE.W #0,D0
	LEA BuffSA,A1
	MOVE.W PuntSAE,A2
	MOVE.B #$12,(A2)+
	MOVE.B #$34,(A2)+
	MOVE.B #$56,(A2)+
	MOVE.B #$78,(A2)+
	MOVE.B #$90,(A2)+
	MOVE.W A2,PuntSAE
	MOVE.W #1,-(A7)
	MOVE.W #0,-(A7)
	MOVE.L #$4008,-(A7)

	BSR SCAN
	MOVE.W PuntSAL,A4

	BREAK

	ORG $4008
BUFFER	DC.B	$d,$a,$31,$32,$33,$d,$a,$34,$35,$36

PRPRINT:
	BSR INIT
	MOVE.W #8,-(A7)
	MOVE.W #0,-(A7)
	MOVE.L #$4008,-(A7)
	BSR PRINT 
	BREAK

*BUFFER: DS.B 2100 * Buffer para lectura y escritura de caracteres
PARDIR: DC.L 0 * Direcci ́on que se pasa como par ́ametro
PARTAM: DC.W 0 * Tamano que se pasa como par ́ametro
CONTC: DC.W 0 * Contador de caracteres a imprimir
DESA: EQU 0 * Descriptor l ́ınea A
DESB: EQU 1 * Descriptor l ́ınea B
TAMBS: EQU 30 * Tamano de bloque para SCAN
TAMBP: EQU 7 * Tamano de bloque para PRINT
* Manejadores de excepciones
INICIO:
	MOVE.L #BUS_ERROR,8 * Bus error handler
	MOVE.L #ADDRESS_ER,12 * Address error handler
	MOVE.L #ILLEGAL_IN,16 * Illegal instruction handler
	MOVE.L #PRIV_VIOLT,32 * Privilege violation handler
	MOVE.L #ILLEGAL_IN,40 * Illegal instruction handler
	MOVE.L #ILLEGAL_IN,44 * Illegal instruction handler
	BSR INIT
	MOVE.W #$2000,SR * Permite interrupciones
BUCPR:
	MOVE.W #TAMBS,PARTAM * Inicializa par ́ametro de tama~no
	MOVE.L #BUFFER,PARDIR * Par ́ametro BUFFER = comienzo del buffer
OTRAL:
	MOVE.W PARTAM,-(A7) * Tama~no de bloque
	MOVE.W #DESA,-(A7) * Puerto A
	MOVE.L PARDIR,-(A7) * Direcci ́on de lectura
ESPL:
	BSR SCAN
	ADD.L #8,A7 * Restablece la pila
	ADD.L D0,PARDIR * Calcula la nueva direcci ́on de lectura
	SUB.W D0,PARTAM * Actualiza el n ́umero de caracteres le ́ıdos
	BNE OTRAL * Si no se han le ́ıdo todas los caracteres
			  * del bloque se vuelve a leer
	MOVE.W #TAMBS,CONTC * Inicializa contador de caracteres a imprimir
	MOVE.L #BUFFER,PARDIR * Par ́ametro BUFFER = comienzo del buffer
OTRAE:
	MOVE.W #TAMBP,PARTAM * Tama~no de escritura = Tama~no de bloque
ESPE:
	MOVE.W PARTAM,-(A7) * Tama~no de escritura
	MOVE.W #DESB,-(A7) * Puerto B
	MOVE.L PARDIR,-(A7) * Direcci ́on de escritura
	BSR PRINT
	ADD.L #8,A7 * Restablece la pila
	ADD.L D0,PARDIR * Calcula la nueva direcci ́on del buffer
	SUB.W D0,CONTC * Actualiza el contador de caracteres
	BEQ SALIR * Si no quedan caracteres se acaba
	SUB.W D0,PARTAM * Actualiza el tama~no de escritura
	BNE ESPE * Si no se ha escrito todo el bloque se insiste
	CMP.W #TAMBP,CONTC * Si el n

	BHI OTRAE * Siguiente bloque
	MOVE.W CONTC,PARTAM
	BRA ESPE * Siguiente bloque
SALIR:
	BRA BUCPR
BUS_ERROR: BREAK * Bus error handler
	NOP
ADDRESS_ER: BREAK * Address error handler
	NOP
ILLEGAL_IN: BREAK * Illegal instruction handler
	NOP
PRIV_VIOLT: BREAK * Privilege violation handler
	NOP




*$BSVC/68kasm -la es_int.s
*$BSVC/bsvc /usr/local/bsvc/samples/m68000/practica.setup