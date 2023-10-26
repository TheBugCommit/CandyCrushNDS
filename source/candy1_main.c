#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy1_incl.h>


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
char mat_mar[ROWS][COLUMNS];
int seed32;						// semilla de n�meros aleatorios
int level = 10;					// nivel del juego (nivel inicial = 0)
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
	if (code & 1) printf("\x1b[38m\x1b[1;8H %d  ", level);
	if (code & 2) printf("\x1b[39m\x1b[2;8H %d  ", points);
	if (code & 4) printf("\x1b[38m\x1b[1;28H %d ", movements);
	if (code & 8) printf("\x1b[37m\x1b[2;28H %d ", gelees);
}



/* ---------------------------------------------------------------- */
/* candy1_main.c : funci�n principal main() para test de tarea 1D 	*/
/*					(requiere tener implementada la tarea 1E)		*/
/* ---------------------------------------------------------------- */
int main(void)
{
	consoleDemoInit();			// inicializaci�n de pantalla de texto
	printf("candyNDS (prueba tarea 1C)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);

	do							
	{
		inicializa_matriz(matrix, level);
		escribe_matriz_debug(matrix);

		retardo(5);
		printf("\x1b[38m\x1b[3;0H (pulse B see marks matrix)");
		do
		{	swiWaitForVBlank();
			scanKeys();					
		} while (!(keysHeld() & (KEY_B)));
		printf("\x1b[3;0H                                    ");

		elimina_secuencias(matrix, mat_mar);
		escribe_matriz_debug(mat_mar);

		retardo(5);
		printf("\x1b[38m\x1b[3;0H (pulse B see result matrix)");
		do
		{	swiWaitForVBlank();
			scanKeys();					
		} while (!(keysHeld() & (KEY_B)));
		printf("\x1b[3;0H                                     ");
		escribe_matriz_debug(matrix);

		retardo(5);
		printf("\x1b[38m\x1b[3;0H (pulse A(next level)/B(repeat))");
		do
		{	swiWaitForVBlank();
			scanKeys();					
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		printf("\x1b[3;0H                                         ");

		if (keysHeld() & KEY_A)			
		{								
			level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
		}
	} while (1);

	return(0);
}
