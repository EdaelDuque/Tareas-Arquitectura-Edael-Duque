.data
    bufA:  .space 100
    bufB:  .space 100
    headA: .word 0
    headB: .word 0
    flag:  .word 0 
    msgA:  .asciiz "\n--- Vaciando Buffer A (Activo B) ---\n"
    msgB:  .asciiz "\n--- Vaciando Buffer B (Activo A) ---\n"

.text
.globl main

main:

    li $t0, 0xFFFF0000
    li $t1, 2
    sw $t1, 0($t0)
    mfc0 $a0, $12
    ori  $a0, $a0, 0xFF01
    mtc0 $a0, $12

loop_pingpong:

    li $v0, 30
    syscall
    move $s0, $a0

esperar_10s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    bltu $t0, 10000, esperar_10s

    lw $t0, flag
    beq $t0, $zero, cambiar_a_B

    li $t1, 0
    sw $t1, flag
    li $v0, 4
    la $a0, msgB
    syscall
    jal vaciar_B
    j loop_pingpong

cambiar_a_B:

    li $t1, 1
    sw $t1, flag
    li $v0, 4
    la $a0, msgA
    syscall
    jal vaciar_A
    j loop_pingpong

#Funciones de vaciado
vaciar_A:
    la $t2, bufA
    lw $t3, headA
    li $t4, 0
loop_A:
    beq $t4, $t3, fin_A
    addu $t5, $t2, $t4
    lb $a0, 0($t5)
    li $v0, 11
    syscall
    addi $t4, $t4, 1
    j loop_A
fin_A:
    sw $zero, headA
    jr $ra

vaciar_B:
    la $t2, bufB
    lw $t3, headB
    li $t4, 0
loop_B:
    beq $t4, $t3, fin_B
    addu $t5, $t2, $t4
    lb $a0, 0($t5)
    li $v0, 11
    syscall
    addi $t4, $t4, 1
    j loop_B
fin_B:
    sw $zero, headB
    jr $ra

#Manejo de interrupciones
.ktext 0x80000180
    li $k0, 0xFFFF0004
    lb $k1, 0($k0)

    #Filtro Mayúsculas
    blt $k1, 65, salir_int
    bgt $k1, 90, salir_int

    lw $t8, flag
    beq $t8, 1, guardar_en_B

guardar_en_A:
    la $t9, bufA
    lw $t8, headA
    addu $t7, $t9, $t8
    sb $k1, 0($t7)
    addi $t8, $t8, 1
    sw $t8, headA
    j salir_int

guardar_en_B:
    la $t9, bufB
    lw $t8, headB
    addu $t7, $t9, $t8
    sb $k1, 0($t7)
    addi $t8, $t8, 1
    sw $t8, headB

salir_int:
    eret
