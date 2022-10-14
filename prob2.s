.data
vetor: .word 0 9 9 3 4 2 0 6 6 4 1
##### START MODIFIQUE AQUI START #####
##### END MODIFIQUE AQUI END #####
.text
main:
la x12, vetor # vector begin
addi x13, x0, 11 # vector size
addi x14, x0, 0 # type of operation [0: CPF, 1: CNPJ]
jal x1, verificadastro
beq x0,x0,FIM
##### START MODIFIQUE AQUI START #####
verificacpf: 
  addi x10, x0, -1 # attributes a initial undefined value at algorithm response
  addi sp, sp, -8 # allocate stack to receive 2 words
  sw x12, 4(sp) # stores vector start address at stack
  sw x1, 0(sp) # stores function call return address at stack

  addi x5, x0, 0 # result aux variable 
  addi x6, x0, 0 # multiplied aux variable
  addi x7, x0, 10 # multiplier aux variable
  addi, x16, x0, 36 # sets x16 function parameter to 36 (tenth element idx)
  jal x1, assure_digit # calls assure_digit function to assure that the tenth element (first validator digit) is valid
  beq x10, x0, exit_cpf # in the case that x10 register has already been defined as 0 (not valid) algorithm can exit

  addi x5, x0, 0 # result aux variable reset
  addi x6, x0, 0 # multiplied aux variable reset
  addi x7, x0, 11 # multiplier aux variable new value
  addi, x16, x0, 40 # sets x16 function parameter to 40 (eleventh element idx)
  jal x1, assure_digit # calls assure_digit function to assure that the eleventh element (second validator digit) is valid
  beq x10, x0, exit_cpf # in the case that x10 register has already been defined as 0 (not valid) algorithm can exit

  lw x12, 4(sp) # loads original x12 value (vector begin address) from stack
  addi, x28, x12, 40 # sets x28 register to the address of the last vector element
  verify_diff_digits:
    lw x29, 0(x12) # loads element of idx i from vector
    lw x30, 4(x12) # loads element of idx i + 1 from vector
    addi x12, x12, 4 # x12 value goes to next position (i++)
    bne x29, x30, cpf_valid # if two consecutive values are different exits to cpf_valid
    blt x12, x28, verify_diff_digits # while x12 haven't had reach the end of the vector, repeat verify_diff_digits


  addi x10, x0, 0 # in the case of the above loop didn't finish so all digits are equal and CPF is invalid
  beq x0, x0, exit_cpf # calls exit_cpf unconditionally to exit algorithm

  cpf_valid: 
    addi x10, x0, 1 # if this block is called means that the CPF is valid and x10 receives 1
    beq x0, x0, exit_cpf # calls exit_cpf unconditionally to exit algorithm

  assure_digit:
    addi x28, x0, 0 # iterator variable
    addi x29, x7, -1 # loop limit = multiplier aux variable - 1
    mul_loop: 
      lw x30, 0(x12) # loads vector element at x12
      mul x6, x30, x7 # multiplies element at x30 with the multiplier aux variable and stores in the multiplied aux variable
      add x5, x5, x6 # result aux variable = result aux variable + multiplied aux variable
      addi x7, x7, -1 # multiplier aux variable --
      addi x12, x12, 4 # x12 goes to next position on vector
      addi x28, x28, 1 # iterator++
      blt x28, x29, mul_loop # in the case that the iterator is lower than the loop limit, mul_loop is called

    addi x30, x0, 10 # x30 turns into const value 10
    mul x5, x5, x30 # result aux variable is multiplied by 10
    rem x5, x5, x13 # result aux = (result aux) % (11)
    lw x12, 4(sp) # loads original x12 value (begin of vector)
    add x12, x12, x16 # gets first or second validator digit according to function call
    lw x30, 0(x12) # loads validator digit to x30
    bne x30, x5, not_valid # in the case of the validator digit differs from result aux goes to not_Valid block
    jalr x0, 0(x1) # return to call address

    not_valid:
      addi x10, x0, 0 # attribute x10 register to 0, indicating that CPF is not valid
      jalr x0, 0(x1) # return to call address

  exit_cpf: 
    lw x1, 0(sp) # load initial function call return address at stack
    lw x12, 4(sp) # loads x12 original value back to stack
    addi sp, sp, 8 # deallocate stack to receive 2 word values
    jalr x0, 0(x1) # return to verificacpf call address

verificacnpj: 
  addi x10, x0, 9
  jalr x0, 0(x1)

verificadastro: 
  addi sp, sp, -4 # allocate stack to receive 1 word value
  sw x1, 0(sp) # stores function call return address at stack

  beq x14, x0, call_cpf # in the case that x14 parameter is 0, calls call_cpf block

  addi x5, x0, 1 # stores constant value 1 in x5
  beq x14, x5, call_cnpj # in the case that x14 parameter is 1, calls call_cnpj block

  call_cpf:
    jal x1, verificacpf # calls verificacpf
    bge x0, x0, exit_verifica # calls exit_verifica unconditionally to exit function
  call_cnpj:
    jal x1, verificacnpj # calls verificacnpj
    bge x0, x0, exit_verifica # calls exit_verifica unconditionally to exit function

  exit_verifica: 
    lw x1, 0(sp) # load function call return address at stack
    addi sp, sp, 4 # deallocate stack to receive 1 word value
    jalr x0, 0(x1) # return to verificadastro call address
##### END MODIFIQUE AQUI END #####
FIM: add x1, x0, x10