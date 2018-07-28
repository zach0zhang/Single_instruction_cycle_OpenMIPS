   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
   lui  $3,0xffff
   ori  $3,$3,0xf000
   ori  $2,$0,0x0001
   
_loop:   
   lw   $4,0x10($3)
   andi $5,$4,0x00ff
   srl  $4,$4,8
   lw	$6,0x30($3)
   ori  $2,$0,0x0001
   beq  $6,$2,s1
   ori  $2,$0,0x0002
   beq  $6,$2,s2
   ori  $2,$0,0x0004
   beq  $6,$2,s3
   j s4
s1:
   addu $1,$5,$4
   j s4
s2:
   subu $1,$5,$4
   j s4
s3:
   mul  $1,$5,$4
s4:
   sw 	$1,0x0($3)
   sw	$1,0x20($3)
   j _loop
   nop
