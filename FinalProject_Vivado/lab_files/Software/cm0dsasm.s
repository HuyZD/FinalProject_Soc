
LCD_BASE    EQU     0x50000000
LCD_RS      EQU     (1 << 5)    ; 0x20
LCD_EN      EQU     (1 << 6)    ; 0x40


						PRESERVE8
                		THUMB

        				AREA	RESET, DATA, READONLY
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
        				DCD		0
        				DCD		0
              
                AREA |.text|, CODE, READONLY

                ALIGN   4
                ENTRY
        EXPORT  Reset_Handler

Reset_Handler   PROC
				; 1. Setup LCD
				BL      LCD_init
				; 2. Print Message
				LDR     R0, =my_string
				BL      lcd_write_string
				; 3. Trap CPU
AGAIN
				B       AGAIN
				ENDP


; PART 2: STRUCTURAL CHANGES (REFACTORED DRIVER)
; NEW FUNCTION: lcd_send_byte
; REPLACES: lcd_cmd AND lcd_data
; INPUT: R0 = Data Byte, R1 = Mode (0=Cmd, 1=Data)
; CHANGE: G?p 2 hàm thành 1 d? thay d?i c?u trúc code

lcd_send_byte  PROC
        PUSH    {R4, R5, LR}
        
        MOV     R4, R0              ; Save Data
        MOV     R5, R1              ; Save Mode

        ; Phase 1: High Nibble 
		
		
        LSRS    R0, R4, #4          ; Shift Right 4
        MOV     R1, R5              ; Restore Mode
        BL      lcd_send_nibble      ; Call physical layer

        ; Phase 2: Low Nibble 
        MOV     R0, R4              ; Restore Data
        MOVS    R2, #0x0F           ; Mask
        ANDS    R0, R0, R2
        MOV     R1, R5              ; Restore Mode
        BL      lcd_send_nibble      ; Call physical layer

        ; Phase 3: Post-write Delay 
        LDR     R0, =2000
        BL      Delay

        POP     {R4, R5, PC}
        ENDP


LCD_init PROC
        PUSH    {LR}

        ; Power ON Wait
        LDR     R0, =50000
        BL      Delay

        ; Reset Sequence (Raw Nibbles)
        ; Loop unrolling removed, manual calls for clarity
        
        ; Step 1: 0x03
        MOVS    R0, #3
        MOVS    R1, #0
        BL      lcd_send_nibble
        LDR     R0, =5000
        BL      Delay

        ; Step 2: 0x03
        MOVS    R0, #3
        MOVS    R1, #0
        BL      lcd_send_nibble
        LDR     R0, =2000
        BL      Delay

        ; Step 3: 0x03
        MOVS    R0, #3
        MOVS    R1, #0
        BL      lcd_send_nibble
        LDR     R0, =2000
        BL      Delay

        ; Step 4: 0x02 (4-bit Interface)
        MOVS    R0, #2
        MOVS    R1, #0
        BL      lcd_send_nibble
        LDR     R0, =2000
        BL      Delay

        ;  Config Sequence (Using merged function)
        
        ; Function Set (0x28)
        MOVS    R0, #0x28
        MOVS    R1, #0              ; Mode 0 = CMD
        BL      lcd_send_byte

        ; Display Control (0x0C)
        MOVS    R0, #0x0C
        MOVS    R1, #0
        BL      lcd_send_byte

        ; Clear Display (0x01)
        MOVS    R0, #0x01
        MOVS    R1, #0
        BL      lcd_send_byte
        
        ; Clear needs extra wait
        LDR     R0, =60000
        BL      Delay

        ; Entry Mode (0x06)
        MOVS    R0, #0x06
        MOVS    R1, #0
        BL      lcd_send_byte

        POP     {PC}
        ENDP


; RENAMED FUNCTION: lcd_send_nibble
; PREVIOUSLY: lcd_send_nibble

lcd_send_nibble  PROC
        PUSH    {R4, R5, LR}
        
        ; Construct Output Byte in R4
        MOVS    R4, #0
        
        ; 1. Handle RS (R1)
        LSLS    R2, R1, #5          ; Shift RS to bit 5
        ORRS    R4, R4, R2
        
        ; 2. Handle Data (R0)
        MOVS    R2, #0x0F
        ANDS    R0, R0, R2
        ORRS    R4, R4, R0          ; R4 is now [0][RS][0][DATA]
        
        LDR     R5, =LCD_BASE

        ; 3. Pulse Sequence
        ; Setup
        STR     R4, [R5]
        MOVS    R0, #50
        BL      Delay
        
        ; Enable High
        MOVS    R2, #LCD_EN
        MOV     R3, R4
        ORRS    R3, R3, R2
        STR     R3, [R5]
        MOVS    R0, #100            ; Increased for safety
        BL      Delay
        
        ; Enable Low
        STR     R4, [R5]
        MOVS    R0, #50
        BL      Delay

        POP     {R4, R5, PC}
        ENDP


; RESTRUCTURED LOOP: Lcd_String_Out
; PREVIOUSLY: LCD_PutString

lcd_write_string  PROC
        PUSH    {R4, LR}
        MOV     R4, R0              ; Ptr copy
        
next_char
        LDRB    R0, [R4]            ; Load
        CMP     R0, #0              ; Check Null
        BEQ     write_string_done             ; Exit if 0
        
        MOVS    R1, #1              ; Mode 1 = DATA (Change from previous logic)
        BL      lcd_send_byte      ; Call Merged Function
        
        ADDS    R4, R4, #1          ; Increment
        B       next_char           ; Loop

write_string_done
        POP     {R4, PC}
        ENDP


Delay   PROC
		CMP     R0, #0
        BEQ     end_loop
decr_loop  SUBS    R0, R0, #1
        BNE     decr_loop	
end_loop BX      LR
        ENDP

; DATA

        ALIGN   4
my_string       DCB     "Huy Duong", 0

        END