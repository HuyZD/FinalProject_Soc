

;------------------------------------------------------------------------------------------------------
; Design and Implementation of an AHB Interrupt Mechanism  
; 1)Input characters from keyboard (UART) and output to the terminal (using interrupt)
; 2)A counter is incremented from 1 to 10 and displayed on the 7-segment display (using interrupt)
;------------------------------------------------------------------------------------------------------



; Vector Table Mapped to Address 0 at Reset

						PRESERVE8
                		THUMB

        				AREA	RESET, DATA, READONLY	  			; First 32 WORDS is VECTOR TABLE
        				EXPORT 	__Vectors
					
__Vectors		    	DCD		0x00003FFC
        				DCD		Reset_Handler
        				DCD		0  			
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				
        				; External Interrupts
						        				
        				DCD		Timer_Handler
        				DCD		UART_Handler
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
              
                AREA |.text|, CODE, READONLY
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY
			; Configure NVIC
				; Set interrupt priority registers
				LDR  R0, =0xE000E400      
				;LDR  R1, [R0]    	         
				;MOVS R2, #0xFFFF            
				;BICS R1, R1, R2         

				LDR R1, =0x00004000    ;uart 40, timer 00       
				;ORRS R1, R1, R2          

				STR  R1, [R0]            


                ;Set interrupt Enbale Register
				LDR R0, =0xE000E100
				LDR R1, =0x00000003
				STR R1, [R0]
		

				;Configure the timer
				LDR R1, =0x52000000
				LDR R0, =0x00FAF080 ; 50tr clock
				STR R0, [R1]  ; store R0 into Load register
				
				LDR R1, =0x52000008  ;get addr control register
				MOVS R0, #0x07
				STR R0, [R1]


                LDR     R5, =0x00000030		;counting-up counter, start from '0' (ascii=0x30)  

AGAIN						
				B		AGAIN		


				ENDP

Timer_Handler   PROC
                EXPORT Timer_Handler
				
				PUSH	{R0, R1,R2, LR}
				LDR		R1, =0x5200000C
				LDR		R0, =0x01
				STR		R0, [R1]
				
				LDR		R1, =0x51000000
				STR		R5, [R1]
				ADDS	R5, R5, #0x01
				CMP		R5, #0x3A
				BNE		NEXT
				LDR		R1, =0x52000008
				LDR		R0, =0x00
				STR	    R0, [R1]
				;LDR		R2, =0xE000E180
				;MOVS	R0, #0x1
				;STR		R0, [R2]
NEXT			
				LDR		R1, =0x51000000
				MOVS	R0, #' '
				STR		R0, [R1]
				POP		{R0, R1,R2, PC}
                ENDP

UART_Handler    PROC
                EXPORT UART_Handler
				; write your code here
				PUSH	{R0, R1, LR}
				LDR 	R1, =0x51000000
				
				
				LDR		R0,[R1]
				STR		R0, [R1]
			

				POP     {R0, R1, PC}
				
			

                ENDP

				ALIGN 		4					 ; Align to a word boundary

		END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
   