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
	TIMER0_CR = 0x00;  		// inicialmente los timers no generan interrupciones
	irqSet(IRQ_TIMER0, rsi_timer0);		// cargar direcciones de las RSI
	irqEnable(IRQ_TIMER0);				// habilitar la IRQ correspondiente
	TIMER1_CR = 0x00;
	irqSet(IRQ_TIMER1, rsi_timer1);
	irqEnable(IRQ_TIMER1);
	TIMER2_CR = 0x00;
	irqSet(IRQ_TIMER2, rsi_timer2);
	irqEnable(IRQ_TIMER2);
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

	consoleDemoInit();			// inicializaci�n de pantalla de texto
	printf("candyNDS (version 2: graficos)\n");

	do {
		swiWaitForVBlank();
		scanKeys();
		if (keysHeld() & KEY_Y) {
			if (timer3_on) desactiva_timer3();
			else activa_timer3();
		}	
	} while(1);

	
	return(0);					
}

