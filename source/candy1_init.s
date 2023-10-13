@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: yyy.yyy@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinaci�n: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuraci�n indicado por par�metro (a
@;	obtener de la variable global 'mapas'), y despu�s cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocar� la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocar� la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = n�mero de mapa de configuraci�n
	.global inicializa_matriz
inicializa_matriz:
		push {r1-r7, lr}		@;guardar registros utilizados
		
		mov r7, r0				@;copia @matriu
		ldr r4, =mapas			@;obtenir mapa de configuració
		mov r3, #ROWS
		mov r5, #COLUMNS
		mul r5, r3
		mla r4, r1, r5, r4		@;r4 = @mapa_config

		mov r1, #0				@; i = 0; (ROWS)
		mov r5, #0				@; offset r0

		.Lfor_rows:
			mov r2, #0				@; j = 0; (COLS)
			.Lfor_cols:
				ldrb r6, [r4]		@; r6 = mapas[i][j]

				.Lif_varaible:

					tst r6,	#7	 		 	@; si espai buit, generar numbero aleatori
					beq .Lwhile_random

					strb r6, [r7, r5] 		@; Copiar element mapa config a matriu
					b .Lend_if_varaible

					.Lwhile_random:
						mov r0, #6			@; n valor aleatori
						bl mod_random
						add r0, r6      	@; + (0 o 8 o 16) a resultat per tenir gelatines diferents
						add r0, #1			@; +1 a resultat per tenir rang 1 - 6
						strb r0, [r7, r5]	@; matriu[i][j] = random

						mov r0, r7				@; restaura copia @matriu 
						mov r3, #NORTH			@; Crida cuenta repeticiones orientacio Nort
						bl cuenta_repeticiones 
						cmp r0, #3				@; reps. >= 3 tornar a generar numero 
						bhs .Lwhile_random

						mov r0, r7				@; restaura copia @matriu 
						mov r3, #WEST			@; Crida cuenta repeticiones orientacio Oest
						bl cuenta_repeticiones 
						cmp r0, #3				@; reps. >= 3 tornar a generar numero 
						bhs .Lwhile_random
					.Lend_while_random:
				.Lend_if_varaible:

				add r2, #1			@; j++;

				add r4, #1			@; @mapa_config + 1
				add r5, #1			@; offset r0 ++

				cmp r2, #COLUMNS		@; j < #COLUMNS
				blo .Lfor_cols
			.Lend_for_cols:

			add r1, #1			@; i++;

			cmp r1, #ROWS 		@; i < #ROWS
			blo .Lfor_rows
		.Lend_for_rows:
		
		pop {r1-r7, pc}			@;recuperar registros y volver



@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicaci�n de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiar� la matriz original en 'mat_recomb1', para luego ir
@;	escogiendo elementos de forma aleatoria y colocandolos en 'mat_recomb2',
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocar� la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocar� la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocar� la rutina 'hay_combinacion' (ver fichero "candy1_comb.s")
@;		* se supondr� que siempre existir� una recombinaci�n sin secuencias y
@;			con combinaciones
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {r1-r10, lr}
		
		mov r1, r0					@; Copy @matrix to r1
		mov r2, #ROWS
		mov r3, #COLUMNS
		mul r4, r2, r3				@; r4 = #ROWS * #COLUMNS

		@; copy original matrix to mat_recomb1

		ldr r2, =mat_recomb1		@; r1 = @mat_recomb1
		ldr r6, =mat_recomb2		@; r6 = @mat_recomb2
		mov r3, #0					@; r3 = offset
		.Lfor_mat_combs:
			ldrb r5, [r1, r3]		@;orig_matrix_elem = matrix[i][j]

			mov r0, r5
			bl is_element
			strb r0, [r2, r3]		@; mat_recomb1[i][j] = value

			.Lif_is_not_element:
				cmp r0, #0
				bne .Lelse_if_is_jelly
				strb r5, [r6, r3] 		@; mat_recomb2[i][j] = value (0,8,16,7,15)
				b .Lend_is_not_element_if
			.Lelse_if_is_jelly:
				mov r0, r5
				bl is_jelly
				cmp r0, #0
				beq .Lelse_is_element
				strb r0, [r6, r3] 		@; mat_recomb2[i][j] = value (8,16)
				b .Lend_is_not_element_if
			.Lelse_is_element:
				mov r0, #0
				strb r0, [r6, r3] 			@; mat_recomb2[i][j] = 0
			.Lend_is_not_element_if:

			add r3, #1				@; offset ++
			cmp r3, r4
			blo .Lfor_mat_combs 
		.Lend_for_mat_combs:

		mov r10, r1					@; r10 = @matrix
		mov r5, r2					@; r5 = @mat_recomb1
		mov r7, #0					@; offset = 0
		.Lfor_orig_mat:
			.Lif_is_element:
				ldrb r0, [r10, r7]		@; r0 = matrix[i][j]	
				bl is_element			@; if (!is_element) continue;
				cmp r0, #0
				beq .Lend_if_is_element

				.Lwhile_sequence:
					.Lwhile_mod_random:			 
						mov r0, r4 				@; while(!is_element(mat_recomb1[random][random]))
						bl mod_random
						mov r8, r0				@; r8 = random

						ldrb r3, [r5, r8]		@; r3 = mat_recomb1[random][random]

						mov r0, r3
						bl is_element			
						cmp r0, #0
						beq .Lwhile_mod_random
					.Lend_while_mod_random:

					ldrb r9, [r6, r7]			@; value = mat_recomb2[i][j]
					add r3, r9
					strb r3, [r6, r7]			@; mat_recomb2[i][j] = mat_recomb2[i][j] + mat_recomb1[random][random]

					mov r0, r7					@; r0 = offset
					sub sp, #8
					mov r1, sp					@; @row
					add r2, sp, #4				@; @column
					bl get_row_columun
					ldr r2, [r1, #4]			@; r2 = column
					ldr r1, [r1]				@; r1 = row
					add sp, #8

					@; check if exists sequence
					.Lif_exists_sequence:
						cmp r2, #2 				@; if(j >= 2) 
						movlo r0, #0
						movhs r0, r6			@; r0 = @mat_recomb2
						movhs r3, #WEST
						blhs cuenta_repeticiones
						cmp r0, #3				@; if(reps >= 3)
						bhs .Lthen_exists_sequence

						cmp r1, #2				@; if(i >= 2)
						movlo r0, #0
						movhs r0, r6			@; r0 = @mat_recomb2
						movhs r3, #NORTH
						blhs cuenta_repeticiones 
						cmp r0, #3				@; if(reps >= 3)
						blo .Lend_exists_sequence_if
					.Lthen_exists_sequence:
						strb r9, [r6, r7]		@; recover mat_recomb2 and repeat process
						b .Lwhile_sequence
					.Lend_exists_sequence_if:
												@; TODO control infinite loop 
				.Lend_while_sequence:

				mov r0, #0						
				strb r0, [r5, r8]				@; mat_recomb1[rand][rand] = 0
			.Lend_if_is_element:

			add r7, #1				@; offset++
			cmp r7, r4
			blo .Lfor_orig_mat
		.Lend_for_orig_mat:

		@; copy mat_recomb2 to @matrix
		mov r1, #0					@; r1 = offset
		.Lfor_copy_mat_comb2:
			ldrb r2, [r6, r1]		@; value from mat_recomb2
			strb r2, [r10, r1]
		
			add r1, #1				@; offset ++
			cmp r1, r4				@; while (offset < ROWS*COLUMNS)
			blo .Lfor_copy_mat_comb2 
		.Lend_for_copy_mat_comb2:

		mov r0, r10					@; return @matrix

		pop {r1-r10, pc}

@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un n�mero aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el par�metro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustar� autom�ticamente a estos valores m�nimo y m�ximo
@;	Par�metros:
@;		R0 = el rango del n�mero aleatorio (n)
@;	Resultado:
@;		R0 = el n�mero aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r1-r4, lr}
		
		cmp r0, #2				@;compara el rango de entrada con el mínimo
		bge .Lmodran_cont
		mov r0, #2				@;si menor, fija el rango mínimo
	.Lmodran_cont:
		and r0, #0xff			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4			@; R0 devuelve número aleatorio restringido a rango
		
		pop {r1-r4, pc}



@; random(): rutina para obtener un n�mero aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (tambi�n se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = direcci�n de la variable 'seed32'
	ldr r1, [r0]				@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
