.org 0x200
.equ dataSize = 10;
data1: .db 96,70,47,30,42,30,10,48,100,100
data2: .db '+','-','+','-','/','/','+','-','*', '*'
data3: .db 3,4,7,9,0,3,1,1,10,10

ldi r22, dataSize    ; For referencing/comparing to dataSize
ldi r20, dataSize	 ; For comparing & incremening Z pointer, determines Z's increment level
ldi r25, dataSize	 ; For comparing & incrementing X pointer, determines X's increment level

ldi r21, 0			 ; Just an additional variable/space, r23 gets moved to r21 in each loop run under getDatax
ldi r24, 0			 ; Just an additional variable/space, used to help when multiplication result is within 8-bits.


ldi r17, 0x00;  Storing value from Data1 here
ldi r18, 0x00;  Storing value from Data2 here
ldi r19, 0x00;  Storing value from Data3 here

call Main            ; Main Function
nop					 ; Right-click and 'Run to Cursor' to see final results in memory.

MAIN:
call getData1		 
call getData2
call getData3
call operateData
dec r20			     ; decrements from 10 to 0, and with each decrement, the increment on Z pointer increases proportionally (0 - 10). Helps loop run 10 times aswell.
brne MAIN			 ; If Z != 0, branch.
ret					 

incrementerZ:
cpse r21, r22
inc Zl
cpse r21, r22
inc r21
cpse r21, r22
rjmp incrementerZ
ret

incrementerX:
cpse r21, r25		 ; if r21 == r25, skip next instruction
inc Xl				 ; Increment low-byte of pointer X
cpse r21, r25		 
inc r21				 ; Increment r21
cpse r21, r25
brne incrementerX	 ; rjmp back upto subroutine
ret

/* 
Suppose we have a data set of size 3.
 If r21 is 3 then cpse will be true as r21 == r25 (3 = 3). Hence, Zl nor r21 will not be incremented, and the routine will end. 
 If r21 is 2 then cpse will be false as (2 != 3). Hence, Zl and r21 will be incremented once, and the routine will end.
 If r21 is 1 then cpse will be false as (1 != 3). Following it, Zl and r21 will be incremented twice. 
 If r21 is 0 then cpse will be false as (0 != 3). Following it, Zl and r21 will be incremented thrice.
 Similar scheme follows for incrementation of pointer X.
 Since r21 depends on the value of r20, which in turn depends on the dataset size, the incrementing subroutine
 will help index all three data sets in parallel.
 */

	
 /* Extracts data1 from ROM and moves to RAM GPRs */
getData1:
ldi ZH, HIGH(data1<<1)    ; Access low-byte of data 1
ldi ZL, LOW(data1<<1)     ; Access high-byte of data 1
mov r21, r20			  ; Move increment level to r21
call incrementerZ		  ; Apply increment level, call incrementing subroutine
LPM r17, Z				  ; Store data Z points to in r17
ret

 /* Extracts data2 from ROM and moves to RAM GPRs */
getData2:				  
ldi ZH, HIGH(data2<<1)
ldi ZL, LOW(data2<<1)
mov r21, r20
call incrementerZ
LPM r18, Z
ret

 /* Extracts data3 from ROM and moves to RAM GPRs */
getData3:				   
ldi ZH, HIGH(data3<<1)
ldi ZL, LOW(data3<<1)
mov r21, r20
call incrementerZ
LPM r19, Z
ret

/* Checks and applies relevant operation */
operateData:
cpi r18, 43				   ; if required operation decimal code matches with decimal code for addition, branch to Addition subroutine
breq Addition
cpi r18, 45				   ; if required operation decimal code matches with decimal code for subtraction, branch to Subtraction subroutine
breq Subtraction
cpi r18, 42				   ; if required operation decimal code matches with decimal code for multiplication, branch to Multiplication subroutine
breq Multiplication
cpi r18, 47 			   ; if required operation decimal code matches with decimal code for multiplication, branch to Multiplication subroutine
breq Division
ret

/* Stores results to IRAM */
storeData:
ldi XH, HIGH(0x100);	   ; Set pointer X high-byte to the high-byte of (0x100) RAM
ldi XL, LOW(0x100);		   ; Set pointer X low-byte to the low-byte of(0x100)  RAM
mov r21, r20			   ; Move increment level to r21
call incrementerX		   ; Apply incremenation to pointer, calling incrementerX subroutine
ST X, r17				   ; Store value of r17 to data space pointed by pointer X
ret

/* Stores 16-bit Multiplication results to IRAM */
storeData16bit:
ldi XH, HIGH(0x100);
ldi XL, LOW(0x100);
mov r21, r20
call incrementerX
ST X+, r0	              ; Store value of r0 (stores low-byte of multplication result) to low-byte pointed by pointer X and increment X.
cpse r1, r24			  ; if r1 is equal to 0 (r24 = 0), skip next instruction
inc r25					  ; if there is a value r1, that means we need 16-bits to store result. Hence, X needs one extra overall increment. As such, we increase r25 by 1.
ST X, r1				  ; Store value of r1 (stores high-byte of multplication result) to high-byte pointed by pointer X.
ret


/* Performs addition between r17 and r19 */
Addition:
add r17, r19      ; adds, addition result stored in r17
call storeData	  ; store 8-bit result to IRAM
ret

/* Performs subtraction between r17 and r19 */
Subtraction:
sub r17, r19	  ; subtracts, subtraction result stored in r17
call storeData	  ; store to IRAM
ret

/* Performs multplication between r17 and r19 */
Multiplication:
mul r17, r19			; multiplies, multplication result stored in r0 (low-byte) and r1 (high-byte)
call storeData16bit		; store 16-bit or 8-bit result to IRAM
ret

/* Performs division between r17 and r19, works only when r17 is perfectly divisble by r19, gives zero for any other case */
Division:
ldi r16, 0   ; quotient
cp r17, r16 
breq skip	 ;	if r17 is zero. skip to subroutine 'skip'.
cpse r16, r19 ; if r19 is zero. Skip next instruction
call subLoop
skip:
mov r17, r16 ; move quotient to r17
ldi r16, 0	 ; set quotient back to 0
call storeData ; store r17 to IRAM
ret

/* Subtraction loop, keeps subtracting till r17 != 0 */ 
subLoop:
inc r16        ; increment quotient
sub r17, r19   ; subtract divider from dividend
brne subloop   ; keep repeating until dividend or in other words Z flag != 0
ret