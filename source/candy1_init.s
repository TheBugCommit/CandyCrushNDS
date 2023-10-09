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
						mov r0, #5			@; (n - 1) valor aleatori
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


	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r2, r3-r6, lr}
		
		mov r5, #COLUMNS
		mla r6, r1, r5, r2
		add r4, r0, r6			@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r5, [r4]
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r0, #1				@;R0 = número de repeticiones

		cmp r3, #EAST
		beq .Lconrep_east
		cmp r3, #SOUTH
		beq .Lconrep_south
		cmp r3, #WEST
		beq .Lconrep_west
		cmp r3, #NORTH
		beq .Lconrep_north
		b .Lconrep_end
		
		.Lconrep_east:
			add r2, #1

			cmp r2, #COLUMNS
			bhs .Lconrep_end

			add r4, #1
			ldrb r6, [r4]
			and r3, r6, #7		 

			cmp r3, r5			
			addeq r0, #1

			b .Lconrep_east

		.Lconrep_west:
			sub r2, #1

			cmp r2, #0
			blt .Lconrep_end

			sub r4, #1
			ldrb r6, [r4]
			and r3, r6, #7		 

			cmp r3, r5			
			addeq r0, #1

			b .Lconrep_west

		.Lconrep_north:
			sub r1, #1

			cmp r1, #0
			blt .Lconrep_end

			sub r4, #COLUMNS
			ldrb r2, [r4]
			and r3, r2, #7 

			cmp r3, r5			
			addeq r0, #1

			b .Lconrep_north

		.Lconrep_south:
			add r1, #1

			cmp r1, #ROWS
			bhs .Lconrep_end

			add r4, #COLUMNS
			ldrb r2, [r4]
			and r3, r2, #7 

			cmp r3, r5			
			addeq r0, #1

			b .Lconrep_south

		.Lconrep_end:

		pop {r1-r2, r3-r6, pc}

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
		push {lr}
		
		
		pop {pc}



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
