/*------------------------------------------------------------------------------

	$ candy2_main.c $

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
#include <candy2_incl.h>


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de n�meros aleatorios
int level = 4;					// nivel del juego (nivel inicial = 0)



/* inicializa_interrupciones(): configura las direcciones de las RSI y los bits
	de habilitaci�n (enable) del controlador de interrupciones para que se
	puedan generar las interrupciones requeridas.*/ 
void inicializa_interrupciones()
{
	irqSet(IRQ_VBLANK, rsi_vblank);
	TIMER3_CR = 0x00;
	irqSet(IRQ_TIMER3, rsi_timer3);
	irqEnable(IRQ_TIMER3);
}




/* Test 2D+2H: init background image and move it */
int main(void)
{
	seed32 = time(NULL);		// fijar semilla de n�meros aleatorios
	init_grafA();
	inicializa_interrupciones();

	consoleDemoInit();			
	printf("candyNDS (version 2: graficos)\n");
	printf("\x1b[38m\x1b[4;0H Press Y, move background");

	do {
		scanKeys();
		if (keysHeld() & KEY_Y) {
			if (timer3_on) desactiva_timer3();
			else activa_timer3();
		}	
		swiWaitForVBlank();
	} while(1);

	
	return(0);					
}

