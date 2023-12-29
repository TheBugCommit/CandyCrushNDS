@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: gerard.casass@estudiants.urv.cat		  ===
@;=== Programador tarea 1D: gerard.casass@estudiants.urv.cat		  ===
@;=                                                           		   	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; n�mero de secuencia: se utiliza para generar n�meros de secuencia �nicos,
@;	(ver rutinas 'marcar_horizontales' y 'marcar_verticales') 
	num_sec:	.space 1



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r7, lr}

		mov r7, r0			@; copy @matrix
		mov r6, #0			@; sequence = false
		mov r1, #0			@; i = 0
		mov r5, #0			@; offset per r0

		.Lfor_rows_secu:
			mov r2, #0		@; j = 0
			.Lfor_cols_secu:
				ldrb r4, [r7, r5]			@; r3 = matrix[i][j] 
										
				.Lif_solid_block: 	
					mov r0, r4
					bl is_element
					cmp r0, #0
					movne r0, #0 
					beq .Lend_solid_block_if

					cmp r2, #COLUMNS - 2 	@; if(j < #COLUMNS - 2) 
					movlo r0, r7			@; r0 = @matrix
					movlo r3, #EAST
					bllo cuenta_repeticiones
					cmp r0, #3				@; if(reps >= 3)
					movhs r6, #1
					bhs .Lend_for_rows_secu

					cmp r1, #ROWS - 2		@; if(i < #ROWS - 2)
					movlo r0, r7			@; r0 = @matrix
					movlo r3, #SOUTH
					bllo cuenta_repeticiones 
					cmp r0, #3				@; if(reps >= 3)
					movhs r6, #1
					bhs .Lend_for_rows_secu

				.Lend_solid_block_if:
				
				add r5, #1  		@; increment r0, offset
				add r2, #1			@; j++

				cmp r2, #COLUMNS 	@; j < COLUMNS
				blo .Lfor_cols_secu
			.Lend_for_cols_secu:

			add r1, #1		@; i++
			
			cmp r1, #ROWS	@; i < ROWS
			blo .Lfor_rows_secu
		.Lend_for_rows_secu:

		mov r0, r6			@; sequence = 1 | 0

		pop {r1-r7, pc}


@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o m�s elementos repetidos consecutivamente en horizontal,
@;	vertical o combinaciones, as� como de reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	adem�s, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador �nico para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		push {r0-r2, r4-r8, lr}
		
		mov r8, #0
		ldr r6, =num_sec
		strb r8, [r6]			@; num_sec = 0 

		mov r6, #0
		.Lelisec_for_ini_maks:
			strb r6, [r1, r8]		@; set marks matrix to 0
			add r8, #1
			cmp r8, #ROWS*COLUMNS
			blo .Lelisec_for_ini_maks

		mov r4, r0					@; copy @matrix
		mov r5, r1					@; copy @marks_matrix
		
		bl marcar_horizontales
		bl marcar_verticales

		mov r7, #0					@; r8 = offset
		.Lwhile_remove_elements:
			.Lif_exists_sequence:
				ldrb r6, [r5, r7]		@; r6 = marks_matrix[i][j]
				cmp r6, #0
				beq .Lend_if_exists_sequence

				ldrb r6, [r4, r7]		@; r6 = matrix[i][j]
				.Lif_is_jelly_reduce:
					mov r0, r6
					bl is_jelly
					cmp r0, #0
					beq .Lelse_is_jelly

					mov r8, r0, lsr #4
					mov r8, r8, lsl #3

					@; delete or change jelly sprite
					sub sp, #8
					mov r0, r7					@; r0 = offset
					mov r1, sp					@; @row
					add r2, sp, #4				@; @column
					bl get_row_columun
					ldr r0, [r1]				@; r3 = row			
					ldr r1, [r1, #4]			@; r2 = column
					add sp, #8					@; clear sp
					bl elimina_gelatina

					b .Lend_if_is_jelly_reduce
				.Lelse_is_jelly:
					mov r8, r6, lsr #3 
				.Lend_if_is_jelly_reduce:

				strb r8, [r4, r7]

				@; delete sprite
				sub sp, #8
				mov r0, r7					@; r0 = offset
				mov r1, sp					@; @row
				add r2, sp, #4				@; @column
				bl get_row_columun
				ldr r0, [r1]				@; r3 = row			
				ldr r1, [r1, #4]			@; r2 = column
				add sp, #8					@; clear sp
				bl elimina_elemento

			.Lend_if_exists_sequence:

			add r7, #1			@; offset++
			cmp r7, #ROWS*COLUMNS
			blo .Lwhile_remove_elements
		.Lend_while_remove_elements:

		mov r1, #1
		ldr r0, =update_spr
		strh r1, [r0]			@; update_spr = 1

		pop {r0-r2, r4-r8, pc}

	
@;:::RUTINAS DE SOPORTE:::



@; marcar_horizontales(mat): rutina para marcar todas las secuencias de 3 o m�s
@;	elementos repetidos consecutivamente en horizontal, con un n�mero identifi-
@;	cativo diferente para cada secuencia, que empezar� siempre por 1 y se ir�
@;	incrementando para cada nueva secuencia, y cuyo �ltimo valor se guardar� en
@;	la variable global 'num_sec'; las marcas se guardar�n en la matriz que se
@;	pasa por par�metro 'mat' (por referencia).
@;	Restricciones:
@;		* se supone que la matriz 'mat' est� toda a ceros
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
marcar_horizontales:
		push {r2-r6, lr}
		
		mov r4, r0				@; copy @ orig matrix
		mov r5, r1				@; copy @ marks matrix

		mov r6, #0				@; offset
		.Lfor_mh_orig_matrix:
			.Lif_is_elem_mh:
				ldrb r0, [r4, r6]			@; r0 = orig_matrix[i][j]
				bl is_element		
				cmp r0, #0					@; if(!is_element(r0)) continue;
				beq .Lend_if_is_elem_mh

				ldrb r0, [r5, r6]			@; r0 = marks_matrix[i][j]
				cmp r0, #0					@; if position marked continue
				bne .Lend_if_is_elem_mh

				mov r0, r6					@; r0 = offset
				sub sp, #8
				mov r1, sp					@; @row
				add r2, sp, #4				@; @column
				bl get_row_columun
				ldr r2, [r1, #4]			@; r2 = column
				ldr r1, [r1]				@; r1 = row			
				add sp, #8					@; clear sp
				
				cmp r2, #COLUMNS - 2 	@; if(j < #COLUMNS - 2) 
				movhs r0, #0			
				movlo r0, r4			@; r0 = @orig_matrix
				movlo r3, #EAST
				bllo cuenta_repeticiones
				cmp r0, #3				@; if(reps >= 3)
				movhs r3, r0
				movhs r0, r5			
				movhs r1, r6
				movhs r2, #EAST
				blhs mark_sequence
			.Lend_if_is_elem_mh:
			
			add r6, #1
			cmp r6, #ROWS*COLUMNS
			blo .Lfor_mh_orig_matrix
		.Lend_for_mh_orig_matrix:

		mov r0, r4				@; restore @ orig matrix
		mov r1, r5				@; restore @ marks matrix
		
		pop {r2-r6, pc}



@; marcar_verticales(mat): rutina para marcar todas las secuencias de 3 o m�s
@;	elementos repetidos consecutivamente en vertical, con un n�mero identifi-
@;	cativo diferente para cada secuencia, que seguir� al �ltimo valor almacenado
@;	en la variable global 'num_sec'; las marcas se guardar�n en la matriz que se
@;	pasa por par�metro 'mat' (por referencia);
@;	sin embargo, habr� que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habr�n
@;	almacenado en en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz 'mat' est� marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable 'num_sec' contendr� el siguiente indentificador (>=1)
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
marcar_verticales:
		push {r2-r6, lr}
		
		mov r4, r0				@; copy @ orig matrix
		mov r5, r1				@; copy @ marks matrix

		mov r6, #0				@; offset
		.Lfor_mv_orig_matrix:
			.Lif_is_elem_mv:
				ldrb r0, [r4, r6]			@; r0 = orig_matrix[i][j]
				bl is_element		
				cmp r0, #0					@; if(!is_element(r0)) continue;
				beq .Lend_if_is_elem_mv

				mov r0, r6					@; r0 = offset
				sub sp, #8
				mov r1, sp					@; @row
				add r2, sp, #4				@; @column
				bl get_row_columun
				ldr r2, [r1, #4]			@; r2 = column
				ldr r1, [r1]				@; r1 = row			
				add sp, #8					@; clear sp
				
				cmp r1, #ROWS - 2 			@; if(i < #COLUMNS - 2) 
				movhs r0, #0			
				movlo r0, r4				@; r0 = @orig_matrix
				movlo r3, #SOUTH
				bllo cuenta_repeticiones
				cmp r0, #3					@; if(reps >= 3)
				movhs r3, r0
				movhs r0, r5			
				movhs r1, r6
				movhs r2, #SOUTH
				blhs mark_sequence
			.Lend_if_is_elem_mv:
			
			add r6, #1
			cmp r6, #ROWS*COLUMNS
			blo .Lfor_mv_orig_matrix
		.Lend_for_mv_orig_matrix:

		mov r0, r4				@; restore @ orig matrix
		mov r1, r5				@; restore @ marks matrix
		
		pop {r2-r6, pc}


@; mark_sequence(*matrix, offset, orientation, sequence_length): 
@;	Params:
@;		R0 = @marks_matrix
@;		R1 = offset
@;		R2 = orientation (EAST, SOUTH, WEAST)
@;		R3 = sequence_length
mark_sequence:
		push {r4-r8, lr}

		mov r4, r1								@; r4 = offset
		mov r6, r0								@; r6 = @matrix 

		@; get num_sec to mark
		.Lif_no_exists_sequence:
				.Lif_vertical:
					cmp r2, #SOUTH
					bne .Lend_if_vertical
					
					mov r5, #0					@; i = 0
					mov r8, r4					@; r8 = offset
					.Lwhile_search_intersection:
						cmp r5, r3
						bhs .Lend_while_search_intersection
						
						ldrb r7, [r6, r8]				@; r7 = marks_matrix[i][j]
						cmp r7, #0
						bne .Lend_if_no_exists_sequence

						mov r0, r8
						mov r1, r2
						bl move_offset_by_orientation
						mov r8, r0

						add r5, #1
						b .Lwhile_search_intersection
					.Lend_while_search_intersection:
				
				.Lend_if_vertical:

				ldr r5, =num_sec				@; num_sec++
				ldrb r7, [r5]
				add r7, #1
				strb r7, [r5]
		.Lend_if_no_exists_sequence:

		.Lfor_mark_sequence:
			cmp r3, #0
			bls .Lend_for_mark_sequence

			strb r7, [r6, r4]					@; set mark

			mov r0, r4
			mov r1, r2
			bl move_offset_by_orientation
			mov r4, r0

			sub r3, #1							@; sequence_lenght--
			b .Lfor_mark_sequence
		.Lend_for_mark_sequence:
		
		mov r0, r6								@; restore @matrix 

		pop {r4-r8, pc}

.end
