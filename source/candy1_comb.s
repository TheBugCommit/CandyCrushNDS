@;=                                                               		=
@;=== candy1_combi.s: rutinas para detectar y sugerir combinaciones   ===
@;=                                                               		=
@;=== Programador tarea 1G: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1H: yyy.yyy@estudiants.urv.cat				  ===
@;=                                                             	 	=



.include "../include/candy1_incl.i"


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinaci�n entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia v�lida, incluyendo elementos en gelatinas simples y dobles.
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_combinacion
hay_combinacion:
		push {r1-r8, lr}
		
		mov r7, r0						@; copy matrix 

		mov r8, #0						@; conbination = false

		mov r1, #0						@; i = 0;
		mov r5, #0						@; matrix offset
		.Lfor_rows_hcomb:
			mov r2, #0  				@; j = 0;
			.Lfor_cols_hcomb:
				ldrb r6, [r7, r5]		@; r6 = matrix[i][j]

				.Lif_void:
					mov r0, r6
					bl is_element
					cmp r0, #0
					beq .Lend_void_if

					.Lif_no_last_column:
						cmp r2, #COLUMNS - 1 				@; if (j < COLUMNS - 1)
						bhs .Lend_no_last_column_if

						mov r0, r7
						mov r3, r1							@; r3 = i
						add r4, r2, #1 						@; r4 = j + 1
						bl detect_combination
						cmp r0, #1
						moveq r8, #1						@; conbination = true
						beq .Lend_for_rows_hcomb
					.Lend_no_last_column_if:

					.Lif_no_last_row:
						cmp r1, #ROWS - 1 					@; if (i < ROWS - 1)
						bhs .Lend_no_last_row_if

						mov r0, r7
						add r3, r1, #1						@; r3 = i + 1
						mov r4, r2 							@; r4 = j
						bl detect_combination
						cmp r0, #1
						moveq r8, #1						@; conbination = true
						beq .Lend_for_rows_hcomb
					.Lend_no_last_row_if:
				.Lend_void_if:

				add r2, #1				@; j++
				add r5, #1				@; @matrix offset ++

				cmp r2, #COLUMNS		@; j < COLUMNS
				blo .Lfor_cols_hcomb
			.Lend_for_cols_hcomb:

			add r1, #1					@; i++

			cmp r1, #ROWS				@; i < ROWS
			blo .Lfor_rows_hcomb
		.Lend_for_rows_hcomb:
		
		mov r0, r8						@; return conbination

		pop {r1-r8, pc}


@; detect_combination(*matrix, row_code1, col_code1, row_code2, col_code2):
@;	Given the coordinates of two elements, if possible, swap them, 
@;  and check if there is any combination in any of those coordinates.
@;	Params:
@; 		R0 = @matrix
@; 		R1 = row code1
@; 		R2 = column code 1
@; 		R3 = row code 2
@; 		R4 = column code 2
@;	Result:
@;		R0 = 1 if combination, 0 otherwise 
detect_combination:
	push {r1-r9, lr}
		mov r5, r0								@; copy @matrix
		mov r6, #0								@; combination = false

		mov r7, r4								@; copy column code 2
		mov r8, r2								@; copy column code 1
		mov r9, r1								@; copy row code 1

		.Lif_can_change_codes:
			bl can_change_codes					@; if can change codes => change codes
			cmp r0, #0
			moveq r0, #0
			beq .Lend_can_change_codes_if

			mov r0, r5
			bl change_codes

			mov r4, r5							@; copy @matrix
			bl detectar_orientacion
			cmp r0, #6
			movne r6, #1						@; combination = true
			bne .Lcomb_detected

			mov r1, r3							@; r1 = row code 2
			mov r2, r7							@; r2 = column code 2
			mov r4, r5							@; copy @matrix
			bl detectar_orientacion
			cmp r0, #6
			movne r6, #1						@; combination = true
			bne .Lcomb_detected

			.Lcomb_detected:
			
			mov r0, r5
			mov r1, r9					
			mov r2, r8
			mov r4, r7
			bl change_codes

		.Lend_can_change_codes_if:

		mov r0, r6								@; return combination 

	pop {r1-r9, pc}

@; can_change_codes(*matrix, row_code1, col_code1, row_code2, col_code2):
@;	Given the coordinates of two elements, returns whether it is possible to exchange them
@;	Params:
@; 		R0 = @matrix
@; 		R1 = row code1
@; 		R2 = column code 1
@; 		R3 = row code 2
@; 		R4 = column code 2
@;	Result:
@;		R0 = 1 if can change codes, 0 otherwise 
can_change_codes:
	push {r1-r8, lr}
		mov r8, #COLUMNS
		
		mla r7, r1, r8, r2		@; r7 = offset code 1
		ldrb r5, [r0, r7]		@; r5 = code 1
		
		mla r7, r3, r8, r4		@; r7 = offset code 2
		ldrb r6, [r0, r7]		@; r6 = code 2

		.Lif_can_change:
			mov r0, r6				@; check if code 2 is an element
			bl is_element
			cmp r0, #0				@; if not an element return 0
			beq .Lend_can_change_if

			and r7, r5, #7			@; r7 have 3 lower bits of code 1
			and r8, r6, #7			@; r8 have 3 lower bits of code 2
			cmp r7, r8				@; if(code1 == code2) return 0
			beq .Lend_can_change_if
		.Lend_can_change_if:

		moveq r0, #0				@; If code 2 is not an element, or code1 == code2 return 0
		movne r0, #1				@; if code 2 is an element && code1 != code2 return 1 

	pop {r1-r8, pc}

@; change_codes(*matrix, row_code1, col_code1, row_code2, col_code2):
@;	Given the coordinates of two elements of the array, swap them
@;	Params:
@; 		R0 = @matrix
@; 		R1 = row code1
@; 		R2 = column code 1
@; 		R3 = row code 2
@; 		R4 = column code 2
change_codes:
	push {r0-r8, lr}
		mov r7, #COLUMNS
		
		mla r6, r1, r7, r2		@; r6 = offset code 1
		ldrb r5, [r0, r6]		@; r5 = code 1
		
		mla r8, r3, r7, r4		@; r8 = offset code 2
		ldrb r7, [r0, r8]		@; r7 = code 2

		strb r5, [r0, r8]		@; write code1 => @code2
		strb r7, [r0, r6]		@; write code2 => @code1

	pop {r0-r8, pc}


@;TAREA 1H;
@; sugiere_combinacion(*matriz, *sug): rutina para detectar una combinaci�n
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	v�lida, incluyendo elementos en gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinaci�n (por referencia).
@;	Restricciones:
@;		* se supone que existe por lo menos una combinaci�n en la matriz
@;			 (se debe verificar antes con la rutina 'hay_combinacion')
@;		* la combinaci�n sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocar� la rutina 'mod_random'
@;			 (ver fichero "candy1_init.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n del vector de posiciones (char *), donde la rutina
@;				guardar� las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
	.global sugiere_combinacion
sugiere_combinacion:
		push {lr}
		
		
		pop {pc}




@;:::RUTINAS DE SOPORTE:::



@; generar_posiciones(vect_pos,f,c,ori,cpi): genera las posiciones de sugerencia
@;	de combinaci�n, a partir de la posici�n inicial (f,c), el c�digo de
@;	orientaci�n 'ori' y el c�digo de posici�n inicial 'cpi', dejando las
@;	coordenadas en el vector 'vect_pos'.
@;	Restricciones:
@;		* se supone que la posici�n y orientaci�n pasadas por par�metro se
@;			corresponden con una disposici�n de posiciones dentro de los l�mites
@;			de la matriz de juego
@;	Par�metros:
@;		R0 = direcci�n del vector de posiciones 'vect_pos'
@;		R1 = fila inicial 'f'
@;		R2 = columna inicial 'c'
@;		R3 = c�digo de orientaci�n;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = c�digo de posici�n inicial:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
generar_posiciones:
		push {lr}
		
		
		pop {pc}



@; detectar_orientacion(f,c,mat): devuelve el c�digo de la primera orientaci�n
@;	en la que detecta una secuencia de 3 o m�s repeticiones del elemento de la
@;	matriz situado en la posici�n (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detecci�n de orientaciones en las
@;			que se detectan secuencias, se invocar� la rutina 'mod_random'
@;			(ver fichero "candy1_init.s")
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;		* s�lo se tendr�n en cuenta los 3 bits de menor peso de los c�digos
@;			almacenados en las posiciones de la matriz, de modo que se ignorar�n
@;			las marcas de gelatina (+8, +16)
@;	Par�metros:
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R4 = direcci�n base de la matriz
@;	Resultado:
@;		R0 = c�digo de orientaci�n;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detectar_orientacion:
		push {r3, r5, lr}
		
		mov r5, #0				@;R5 = índice bucle de orientaciones
		mov r0, #4
		bl mod_random
		mov r3, r0				@;R3 = orientación aleatoria (0..3)
	.Ldetori_for:
		mov r0, r4
		bl cuenta_repeticiones
		cmp r0, #1
		beq .Ldetori_cont		@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin		@;hay inicio de secuencia
		add r3, #2
		and r3, #3				@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3				@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont		@;no hay continuación de secuencia
		tst r3, #1
		bne .Ldetori_vert
		mov r3, #4				@;detección secuencia horizontal
		b .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5				@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3				@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for		@;repetir 4 veces
		
		mov r3, #6				@;marca de no encontrada
		
	.Ldetori_fin:
		mov r0, r3				@;devuelve orientación o marca de no encontrada
		
		pop {r3, r5, pc}


.end
