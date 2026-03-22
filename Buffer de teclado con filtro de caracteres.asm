.data
    buffer: .space 1024      # Espacio para almacenar caracteres
    head:   .word 0          # Puntero de escritura (índice)
    msg:    .asciiz "\n--- Contenido del Buffer (20s) ---\n"
    msg_fin: .asciiz "\n--- Buffer Vaciado. Reiniciando contador ---\n"

.text
.globl main

main:

    li $t0, 0xFFFF0000
    li $t1, 2
    sw $t1, 0($t0)

    mfc0 $a0, $12
    ori  $a0, $a0, 0xFF01
    mtc0 $a0, $12

loop_principal:

    li $v0, 30
    syscall
    move $s0, $a0

esperar_20s:

    li $v0, 30
    syscall
    

    subu $t0, $a0, $s0
    

    bltu $t0, 20000, esperar_20s

 
    li $v0, 4
    la $a0, msg
    syscall

    jal imprimir_y_vaciar

    li $v0, 4
    la $a0, msg_fin
    syscall

    j loop_principal

#Proceso de impresión
imprimir_y_vaciar:
    la $t0, buffer
    lw $t1, head
    li $t2, 0

bucle_print:
    beq $t2, $t1, fin_print
    addu $t3, $t0, $t2
    lb $a0, 0($t3)
    li $v0, 11
    syscall
    
    addi $t2, $t2, 1
    j bucle_print

fin_print:
    sw $zero, head
    jr $ra

#Manejador de interrupciones
.ktext 0x80000180

    li $k0, 0xFFFF0004
    lb $k1, 0($k0)

    blt $k1, 65, salir_int
    bgt $k1, 90, salir_int

    la $k0, buffer
    lw $t8, head
    addu $t9, $k0, $t8
    sb $k1, 0($t9)

    addi $t8, $t8, 1
    sw $t8, head

salir_int:
    eret 
