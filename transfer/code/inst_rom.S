   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
   ori  $1,$0,0x0010   # (1) $1 = 0x10                
   jr   $1	       # (2) jump to 0x10
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x10
   ori  $1,$0,0x0020   # (3) $1 = 0x20               
   jalr $2,$1	       # (4) jump to 0x20,$2 = 0x18
   ori  $1,$0,0x0002   # $1 = 0x2
   
   .org 0x20
   ori  $1,$0,0x0003   # (5) $1 = 0x3
   jal  0x30	       # (6) jmup to 0x30,$31 =0x28
   ori  $1,$0,0x0002   # $1 = 0x2
   
   .org 0x30 
   ori  $1,$0,0x0004   # (7) $1 = 0x4
   j  0x40	       # (8) jmup to 0x40
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x40          
   ori  $1,$0,0x0005   # (9) $1 = 0x5   
   b   s1	       # (10) jump to s1
   ori  $1,$0,0x0002   # $1 = 0x2
  
   .org 0x50
s1:
   ori  $1,$0,0x0006   # (11) $1 = 0x6
   bal  s2 	       # (12) jump to s2,$31 = 0x58
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x60
s2:
   ori  $1,$0,0x0007   # (13) $1 = 0x7
   ori  $2,$0,0x0007   # (14) $2 = 0x7
   ori  $3,$0,0x8000   # (15) $3 = 0x8000
   beq  $1,$2,s3       # (16) $1 == $2 ==> jump to s3
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x80
s3:
   ori  $1,$0,0x0008   # (17) $1 = 0x8
   bgtz $1,s4          # (18) $1(0x8) > 0 ==> jump to s4
   ori  $1,$0,0x0002   # $1 = 0x2  

   .org 0x90
s4:
   ori  $1,$0,0x0009   # (19) $1 = 0x9
   bgez $1,s5          # (20) $1(0x9) > 0 ==> jump to s5
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x100
s5:
   ori  $1,$0,0x000a   # (21) $1 = 0xa
   sll  $3,16          # (22) $3 = 0x8000<<16 ==> $3 = 0x80000000
   bgezal $3,s6        # (23) $3(0x80000000) <0 ==> not jump
   ori  $1,$0,0x000b   # (24) $1 = 0xb
   bltz $3,s6          # (25) $3(0x80000000) <0 ==> jump to s6
   ori  $1,$0,0x0002   # $1 = 0x2

   .org 0x120
s6:
   ori  $1,$0,0x000c   # (26) $1 = 0xc
   blez $2,s7          # (27) $2(0x7) > 0 ==> not jump
   ori  $1,$0,0x000d   # (28) $1 = 0xd
   bne  $1,$0,s7       # (29) $1 != $0 ==> jump to s7
   ori  $1,$0,0x0002   # $1 = 0x2
   nop      

   .org 0x140
s7:
   ori  $1,$0,0x000e   # (30) $1 = 0xe
   bltzal $3,s8        # (31) $3(0x80000000) <0 ==> jump to s8, $31 = 0x148
   ori  $1,$0,0x0002   # $1 = 0x2 

   .org 0x150
s8:
   ori  $1,$0,0x000f   # (32) $1 = 0xf
   nop   
    
_loop:
   j _loop
   nop
