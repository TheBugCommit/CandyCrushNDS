/*------------------------------------------------------------------------------

	$ candy1_main.c $

	Programa principal para la pr�ctica de Computadores: candy-crash para NDS
	(2� curso de Grado de Ingenier�a Inform�tica - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: gerard.casass@estudiants.urv.cat
	Programador 2: gerard.casass@estudiants.urv.cat
	Programador 3: gerard.casass@estudiants.urv.cat
	Programador 4: gerard.casass@estudiants.urv.cat

------------------------------------------------------------------------------*/
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
	if (code & 1) printf("\x1b[38m\x1b[1;8H %d ", level);
	if (code & 2) printf("\x1b[39m\x1b[2;8H %d  ", points);
	if (code & 4) printf("\x1b[38m\x1b[1;28H %d ", movements);
	if (code & 8) printf("\x1b[37m\x1b[2;28H %d ", gelees);
}



/* ---------------------------------------------------------------- */
/* candy1_main.c : funci�n principal main() para test de tarea 1E 	*/
/* ---------------------------------------------------------------- */
#define NUMTESTS 14
short nmap[] = {4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 8};
short posX[] = {0, 0, 0, 0, 4, 4, 4, 0, 0, 5, 4, 1, 1, 1};
short posY[] = {2, 2, 2, 2, 4, 4, 4, 0, 0, 0, 4, 3, 3, 5};
short cori[] = {0, 1, 2, 3, 0, 1, 2, 0, 3, 0, 0, 1, 3, 0};
short resp[] = {1, 2, 1, 1, 2, 1, 1, 3, 1, 3, 5, 2, 4, 2};

int main(void)
{
	int ntest = 0;
	int result;

	consoleDemoInit();			// inicializaci�n de pantalla de texto
	printf("candyNDS (prueba tarea 1E)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	level = nmap[ntest];
	actualizar_contadores(1);
	copia_mapa(matrix, level);
	escribe_matriz_debug(matrix);
	do							// bucle principal de pruebas
	{
		printf("\x1b[39m\x1b[2;0H test %d: posXY (%d, %d), c.ori %d",
									ntest, posX[ntest], posY[ntest], cori[ntest]);
		printf("\x1b[39m\x1b[3;0H resultado esperado: %d", resp[ntest]);
		
		result = cuenta_repeticiones(matrix, posY[ntest], posX[ntest], cori[ntest]);
		
		printf("\x1b[39m\x1b[4;0H resultado obtenido: %d", result);
		retardo(5);
		printf("\x1b[38m\x1b[5;19H (pulse A/B)");
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsaci�n tecla 'A' o 'B'
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		printf("\x1b[2;0H                               ");
		printf("\x1b[3;0H                               ");
		printf("\x1b[4;0H                               ");
		printf("\x1b[38m\x1b[5;19H            ");
		retardo(5);
		if (keysHeld() & KEY_A)		// si pulsa 'A',
		{
			ntest++;				// siguiente test
			if ((ntest < NUMTESTS) && (nmap[ntest] != level))
			{				// si n�mero de mapa del siguiente test diferente
				level = nmap[ntest];		// del n�mero de mapa actual,
				actualizar_contadores(1);		// cambiar el mapa actual
				copia_mapa(matrix, level);
				escribe_matriz_debug(matrix);
			}
		}
	} while (ntest < NUMTESTS);		// bucle de pruebas
	printf("\x1b[38m\x1b[5;19H (fin tests)");
	do { swiWaitForVBlank(); } while(1);	// bucle infinito
	return(0);
}