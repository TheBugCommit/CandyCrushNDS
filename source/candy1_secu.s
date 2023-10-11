@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: yyy.yyy@estudiants.urv.cat				  ===
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
		push {lr}
		
		
		pop {pc}


	
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
		push {lr}
		
		
		pop {pc}



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
		push {lr}
		
		
		pop {pc}



.end
