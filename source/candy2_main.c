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
int level = 12;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// n�mero de movimientos restantes
int gelees;						// n�mero de gelatinas restantes


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


/* Test 2C + 2G: background 1 + jelly animation */
int main(void)
{
	seed32 = time(NULL);
	init_grafA();
	inicializa_interrupciones();

	consoleDemoInit();			
	printf("candyNDS (version 2: graficos)\n");

	inicializa_matriz(matrix, level);
	genera_sprites(matrix);
	genera_mapa1(matrix);
	genera_mapa2(matrix);
	escribe_matriz(matrix);
	retardo(5);

	activa_timer2();
	while (timer2_on) swiWaitForVBlank();	

	return(0);					
}

