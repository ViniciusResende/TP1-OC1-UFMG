.data
vetor: .word 1 2 3 4 5 6 7
.text
main:
la x12, vetor # x12 = vector begin
addi x13, x0, 7 # x13 = 7
addi x13, x13, -1 # x13 = 6
slli x13, x13, 2 # x13 = 24 = elements size
add x13, x13, x12 # x13 = vector begin + elements size = vector size
jal x1, inverte
beq x0, x0, FIM
##### START MODIFIQUE AQUI START #####
inverte: 
  addi sp, sp, -12 # allocate stack to receive 3 word values
  sw x1, 8(sp) # stores function call return address at stack
  sw x13 4(sp) # stores vector end address at stack
  sw x12, 0(sp) #  stores vector begin address at stack
  jal x1, elem_swap # calls elem_swap code block

  elem_swap:  
    blt x13, x12, quit_recursion # in the case that the end address of the considered vector is lower than the begin address, the quit_recursion block is called
    lw x28, 0(x12) # loads considered vector first value in x28
    lw x29, 0(x13) # loads considered vector last value in x29
    sw x28, 0(x13) # stores x28 value in the last position of the considered vector
    sw x29, 0(x12) # stores x29 value in the first position of the considered vector
    addi x12, x12, 4 # first element i from the considered vector passes to be i+1
    addi x13, x13, -4 # last element i from the considered vector passes to be i-1
    jal x1, elem_swap # calls elem_swap code block recursively

  quit_recursion:
    lw x12, 0(sp) # load initial vector begin address from stack
    lw x13, 4(sp) # load initial vector end address from stack
    lw x1, 8(sp) # load function call return address at stack
    addi sp, sp, 12 # deallocate stack to receive 3 word values
    addi x10, x12, 0 # attributes the start vector address to x10 register
    jalr x0, 0(x1) # return to call address

##### END MODIFIQUE AQUI END #####
FIM: add x1, x0, x10 # returns "inverte" x10 result value