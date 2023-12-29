/*------------------------------------------------------------------------------

	$ candy2_main.c $

	Programa TEST 2B+2F para la pr�ctica de Computadores: candy-crash para NDS
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
char mat_mar[ROWS][COLUMNS];
int seed32;						// semilla de n�meros aleatorios
int level = 9;					// nivel del juego (nivel inicial = 0)



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
}


/* ----------------------------------------------------------------  */
/* candy1_main.c : TEST 2B+2F										*/
/* ----------------------------------------------------------------  */
int main(void)
{
	seed32 = time(NULL);		// fijar semilla de n�meros aleatorios
	init_grafA();
	inicializa_interrupciones();

	consoleDemoInit();			// inicializaci�n de pantalla de texto
	printf("candyNDS (version 2: graficos)\n");

	inicializa_matriz(matrix, level);
	genera_sprites(matrix);
	genera_mapa1(matrix);
	genera_mapa2(matrix);
	escribe_matriz(matrix);
	do {
		do
		{	swiWaitForVBlank();
			scanKeys();					
		} while (!(keysHeld() & (KEY_B)));

		sugiere_combinacion(matrix, pos_sug);
		reducir_elementos(matrix);
		aumentar_elementos(matrix);
	} while(1);
	
	return(0);
}

