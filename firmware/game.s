_game__stage_0_init:
	push {r0-r7, lr}

	macros__register_value GAME_STAGE 0
	macros__register_value TIM21_ARR GAME__STAGE0_ARR @ ARR.
	macros__register_value TIM21_PSC GAME__STAGE0_PSC @ Prescaler.

	bl _display__fade_out

	bl _display__init

	bl _display__fade_in

	macros__register_value TIM21_CNT 0x0 @ Counter value.

	pop {r0-r7, pc}


_game__stage_1_init:
	push {r0-r7, lr}

	macros__register_bit_sr TIM21_DIER 0 0 @ UIE (Update Interrupt Disable)
	macros__register_value GAME_STAGE 1
	macros__register_value TIM21_ARR GAME__STAGE1_ARR @ ARR.
	macros__register_value TIM21_PSC GAME__STAGE1_PSC @ Prescaler.

	bl _display__fade_out

	ldr r0, =FALLING_BIT_CURRENT_SHAPE_POINTER
	ldr r1, =FALLING_BIT_FIRST_SHAPE_ADDR
	str r1, [r0]
	macros__register_value FALLING_BIT_COUNTER 0
	macros__register_value TRAY_POSITION 0
	macros__register_value GAME_CURRENT_SCORE 0

	bl _display__init_blank
	bl _game__add_tray_to_display_buffer

	bl _display__fade_in

	macros__register_bit_sr TIM21_DIER 0 1 @ UIE (Update Interrupt Enable)
	macros__register_value TIM21_CNT 0x0 @ Counter value.

	pop {r0-r7, pc}


_game__stage_2_init:
	push {r0-r7, lr}

	macros__register_value GAME_STAGE 2
	macros__register_value TIM21_ARR GAME__STAGE2_ARR @ ARR.
	macros__register_value TIM21_PSC GAME__STAGE2_PSC @ Prescaler.

	bl _display__pause
	bl _display__fade_out

	bl _game__init_display_with_score

	bl _display__fade_in

	macros__register_value TIM21_CNT 0x0 @ Counter value.

	pop {r0-r7, pc}


@ Called after _display__shift_down, so the tray is not on display yet.
_game__check_collision:
	push {r0-r7, lr}

	@ Build tray word (save in R2):
	movs r2, 0b11
	lsls r2, 30
	ldr r0, =TRAY_POSITION
	ldr r1, [r0]
	lsrs r2, r1

	@ Get display bottom row (save in R4):
	ldr r3, =DISPLAY_BUFFER_LAST_ADDR
	ldr r4, [r3]

	cmp r4, 0
	beq _ignore_collision_checks
		ands r2, r4
		beq _game_over
			bl _game__score_increase
			macros__register_value DISPLAY_BUFFER_LAST_ADDR 0 @ 1 point at a time.
			b _ignore_collision_checks
		_game_over:
			bl _display__add_boom
			bl _game__stage_2_init
			b _ignore_collision_checks
	_ignore_collision_checks:

	pop {r0-r7, pc}


_game__add_tray_to_display_buffer:
	push {r0-r7, lr}

	@ Build tray word (save in R2):
	movs r2, 0b11
	lsls r2, 30
	ldr r0, =TRAY_POSITION
	ldr r1, [r0]
	lsrs r2, r1

	@ Put in display buffer:
	ldr r3, =DISPLAY_BUFFER_LAST_ADDR
	str r2, [r3]

	pop {r0-r7, pc}


_game__score_increase:
	push {r0-r7, lr}

	ldr r0, =GAME_CURRENT_SCORE
	ldr r1, [r0]

	adds r1, 1
	str r1, [r0]


	pop {r0-r7, pc}


_game__generate_new_row_at_first_address:
	push {r0-r7, lr}


	ldr r0, =FALLING_BIT_CURRENT_SHAPE_POINTER
	ldr r1, [r0] @ R1 is current shape address (EEPROM).
	ldr r2, [r1] @ ROM addr (acutal shape).

	ldr r3, =DISPLAY_BUFFER_FIRST_ADDR
	str r2, [r3] @ Send to display.

	adds r1, 4
	ldr r2, =FALLING_BIT_LAST_SHAPE_ADDR
	cmp r1, r2
	ble _store_new_shape_addr
		ldr r1, =FALLING_BIT_FIRST_SHAPE_ADDR
	_store_new_shape_addr:
	str r1, [r0]

	pop {r0-r7, pc}


_game__move_tray_left:
	push {r0-r7, lr}

	ldr r0, =TRAY_POSITION
	ldr r1, [r0]
	subs r1, 1
	bpl _store_new_tray_position_l
		movs r1, 0
	_store_new_tray_position_l:
	str r1, [r0]

	pop {r0-r7, pc}


_game__move_tray_right:
	push {r0-r7, lr}

	MAX_TRAY_POSITION .req r3
	movs MAX_TRAY_POSITION, 3

	ldr r0, =TRAY_POSITION
	ldr r1, [r0]
	adds r1, 1
	cmp r1, MAX_TRAY_POSITION
	ble _store_new_tray_position_r
		movs r1, MAX_TRAY_POSITION
	_store_new_tray_position_r:
	str r1, [r0]

	pop {r0-r7, pc}


_game__process_lr_buttons:
	push {r0-r7, lr}

	ldr r0, =BUTTON_PROCESSING_LOCKED
	ldr r1, [r0]
	adds r1, r1
	bne _button_processing_locked

		ldr r0, =BTN_L
		push {r0}
		bl _helpers__read_pin
		bcs _after_action_left
			macros__register_value BUTTON_PROCESSING_LOCKED 1
			bl _game__move_tray_left
			bl _helpers__reset_auto_power_off
			b _one_of_buttons_still_pressed
		_after_action_left:

		ldr r0, =BTN_R
		push {r0}
		bl _helpers__read_pin
		bcs _after_action_right
			macros__register_value BUTTON_PROCESSING_LOCKED 1
			bl _game__move_tray_right
			bl _helpers__reset_auto_power_off
			b _one_of_buttons_still_pressed
		_after_action_right:

	_button_processing_locked:

	ldr r0, =BTN_L
	push {r0}
	bl _helpers__read_pin
	bcc _one_of_buttons_still_pressed
		ldr r0, =BTN_R
		push {r0}
		bl _helpers__read_pin
		bcc _one_of_buttons_still_pressed
			macros__register_value BUTTON_PROCESSING_LOCKED 0

	_one_of_buttons_still_pressed:

	pop {r0-r7, pc}


_game__init_display_with_score:
	push {r0-r7, lr}

	bl _display__init_score

	ldr r0, =GAME_CURRENT_SCORE
	ldr r0, [r0]

	movs r4, 2 @ Digit display index (3 digits to display).

	_display_with_score_next_digit:

		movs r2, 0 @ Digit.
		movs r1, r0

		_keep_dividing:
			adds r2, 1
			subs r1, 10
			cmp r1, 0
		bge _keep_dividing

		subs r2, 1 @ We started at 1. R2: updated score.

		movs r5, 10
		movs r3, r2
		muls r3, r5
		movs r1, r0
		subs r1, r3 @ R1: first digit.

		push {r0-r7}

		movs r5, 6
		movs r6, r4
		muls r6, r5
		adds r6, 7
		push {r1, r6}; bl _display__print_digit_on_position

		pop {r0-r7}

		movs r0, r2 @ Updated score: result of intiger division by 10.

		subs r4, 1

	bge _display_with_score_next_digit


	pop {r0-r7, pc}

