@;=                                                               		=
@;=== candy1_utils.s: multiple global utilities                       ===
@;=                                                               		=



.include "../include/candy1_incl.i"


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm

@; is_element(element_code):
@;	Given a code, return whether it is an element (1-6) or something else (7,15) - (0,8,16)
@;	Params:
@; 		R0 = element code
@;	Result:
@;		R0 = element basic code (1-6), 0 otherwise 
	.global is_element
is_element:
	push {r1, lr}
		mov r1, r0				@; copy r0
		
		.Lif_is_elment:
			bl is_void_element
			cmp r0, #1
			beq .Lend_is_element_if

			mov r0, r1
			bl is_solid_or_gap_element
			cmp r0, #1
		.Lend_is_element_if:

		moveq r0, #0			@; is_element = false
		andne r0, r1, #7		@; is_element, get 3 lower bits
	pop {r1, pc}

@; is_void_element(element_code):
@;	Given a code, return if it is an empty space (0,8,16)
@;	Params:
@; 		R0 = element code
@;	Result:
@;		R0 = 1 if is element, 0 otherwise 
	.global is_void_element
is_void_element:
	push {lr}
		tst r0, #7
		moveq r0, #1
		movne r0, #0
	pop {pc}
	
@; is_solid_or_gap_element(element_code):
@;	Given a code, return whether it is a gap or solid block (7, 15)
@;	Params:
@; 		R0 = element code
@;	Result:
@;		R0 = 1 if is element, 0 otherwise 
	.global is_solid_or_gap_element
is_solid_or_gap_element:
	push {lr}
		and r0, #7		
		teq r0, #7
		moveq r0, #1
		movne r0, #0	
	pop {pc}

@; is_jelly(element_code):
@;	given an element code returns jelly code, or 0 if isn't jelly
@;	Params:
@; 		R0 = element code
@;	Result:
@;		R0 = jelly code (8, 16), 0 otherwise 
	.global is_jelly
is_jelly:
	push {r1, lr}
		mov r1, r0				@; copy element code
		
		.Lif_is_jelly:
			bl is_element
			cmp r0, #0
			beq .Lend_is_jelly_if

			mov r0, r1, lsr #3 
			and r0, #3
			cmp r0, #0
			beq .Lend_is_jelly_if
			mov r0, r0, lsl #3
		.Lend_is_jelly_if:
		
	pop {r1, pc}