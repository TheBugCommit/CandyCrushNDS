#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy1_incl.h>


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de n�meros aleatorios
int level = 0;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// n�mero de movimientos restantes
int gelees;						// n�mero de gelatinas restantes



/* actualizar_contadores(code): actualiza los contadores que se indican con el
	par�metro 'code', que es una combinaci�n binaria de booleanos, con el
	siguiente significado para cada bit:
		bit 0:	nivel
		bit 1:	puntos
		bit 2:	movimientos
		bit 3:	gelatinas  */
void actualizar_contadores(int code)
{
	if (code & 1) printf("\x1b[38m\x1b[1;8H %d", level);
	if (code & 2) printf("\x1b[39m\x1b[2;8H %d  ", points);
	if (code & 4) printf("\x1b[38m\x1b[1;28H %d ", movements);
	if (code & 8) printf("\x1b[37m\x1b[2;28H %d ", gelees);
}



/* ---------------------------------------------------------------- */
/* candy1_main.c : funci�n principal main() para test de tarea 1A 	*/
/*					(requiere tener implementada la tarea 1E)		*/
/* ---------------------------------------------------------------- */
int main(void)
{
	seed32 = time(NULL);		// fijar semilla de n�meros aleatorios
	consoleDemoInit();			// inicializaci�n de pantalla de texto
	printf("candyNDS (prueba tarea 1A)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);

	// Test 1A and 1B
	inicializa_matriz(matrix, level);
	do
	{
		escribe_matriz_debug(matrix);

		if(hay_secuencia(matrix)){
			printf("\x1b[39m\x1b[3;0H hay secuencia: SI");
		} else {
			printf("\x1b[39m\x1b[3;0H hay secuencia: NO");
		}

		retardo(5);
		printf("\x1b[38m\x1b[3;19H (pulse A/B)");
		do
		{	swiWaitForVBlank();
			scanKeys();					
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		printf("\x1b[3;0H                               ");

		
		if (keysHeld() & KEY_B)			
		{								
			recombina_elementos(matrix);
		}

		if (keysHeld() & KEY_A)			
		{								
			level = (level + 1) % MAXLEVEL;
			inicializa_matriz(matrix, level);
			actualizar_contadores(1);
		}
	} while (1); 

	return(0);
}