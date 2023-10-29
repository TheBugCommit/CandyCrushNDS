#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy1_incl.h>


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de n�meros aleatorios
int level = 12;					// nivel del juego (nivel inicial = 0)
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
/* candy1_main.c : funci�n principal main() para test de tarea 1F 	*/
/* ---------------------------------------------------------------- */

int main(void) {
	consoleDemoInit();			// inicializaci�n de pantalla de texto
	printf("candyNDS (prueba tarea 1F)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);

	do {
		copia_mapa(matrix, level);
		escribe_matriz_debug(matrix);

		retardo(5);
		printf("\x1b[38m\x1b[3;0H (pulse B drop items)");
		do
		{	swiWaitForVBlank();
			scanKeys();					
		} while (!(keysHeld() & (KEY_B)));
		printf("\x1b[3;0H                              ");


		baja_elementos(matrix);
		escribe_matriz_debug(matrix);

		retardo(5);
		printf("\x1b[38m\x1b[3;0H (pulse A/B)");
		do
		{	swiWaitForVBlank();
			scanKeys();					
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		printf("\x1b[3;0H                              ");


		if (keysHeld() & KEY_A)			
		{								
			level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
		}
	} while (1);

	return 0;
}