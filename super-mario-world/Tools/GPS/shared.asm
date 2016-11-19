macro include_once(target, base, offset)
	if !<base> != 1
		!<base> = 1
		pushpc
		if read3(<offset>*3+$0CB66E) != $FFFFFF
			<base> = read3(<offset>*3+$0CB66E)
		else
			freecode cleaned
			<base>:
			incsrc <target>
			ORG <offset>*3+$0CB66E
			dl <base>
		endif
		pullpc
	endif
endmacro
!change_map16 = 0
macro change_map16()
	%include_once("routines/change_map16.asm", change_map16, $00)
	JSL change_map16
endmacro
!create_smoke = 0
macro create_smoke()
	%include_once("routines/create_smoke.asm", create_smoke, $03)
	JSL create_smoke
endmacro
!erase_block = 0
macro erase_block()
	%include_once("routines/erase_block.asm", erase_block, $06)
	JSL erase_block
endmacro
!give_points = 0
macro give_points()
	%include_once("routines/give_points.asm", give_points, $09)
	JSL give_points
endmacro
!glitter = 0
macro glitter()
	%include_once("routines/glitter.asm", glitter, $0C)
	JSL glitter
endmacro
!kill_sprite = 0
macro kill_sprite()
	%include_once("routines/kill_sprite.asm", kill_sprite, $0F)
	JSL kill_sprite
endmacro
!move_spawn_above_block = 0
macro move_spawn_above_block()
	%include_once("routines/move_spawn_above_block.asm", move_spawn_above_block, $12)
	JSL move_spawn_above_block
endmacro
!move_spawn_below_block = 0
macro move_spawn_below_block()
	%include_once("routines/move_spawn_below_block.asm", move_spawn_below_block, $15)
	JSL move_spawn_below_block
endmacro
!move_spawn_into_block = 0
macro move_spawn_into_block()
	%include_once("routines/move_spawn_into_block.asm", move_spawn_into_block, $18)
	JSL move_spawn_into_block
endmacro
!move_spawn_to_player = 0
macro move_spawn_to_player()
	%include_once("routines/move_spawn_to_player.asm", move_spawn_to_player, $1B)
	JSL move_spawn_to_player
endmacro
!move_spawn_to_sprite = 0
macro move_spawn_to_sprite()
	%include_once("routines/move_spawn_to_sprite.asm", move_spawn_to_sprite, $1E)
	JSL move_spawn_to_sprite
endmacro
!rainbow_shatter_block = 0
macro rainbow_shatter_block()
	%include_once("routines/rainbow_shatter_block.asm", rainbow_shatter_block, $21)
	JSL rainbow_shatter_block
endmacro
!reset_turn_block = 0
macro reset_turn_block()
	%include_once("routines/reset_turn_block.asm", reset_turn_block, $24)
	JSL reset_turn_block
endmacro
!shatter_block = 0
macro shatter_block()
	%include_once("routines/shatter_block.asm", shatter_block, $27)
	JSL shatter_block
endmacro
!spawn_bounce_sprite = 0
macro spawn_bounce_sprite()
	%include_once("routines/spawn_bounce_sprite.asm", spawn_bounce_sprite, $2A)
	JSL spawn_bounce_sprite
endmacro
!spawn_item_sprite = 0
macro spawn_item_sprite()
	%include_once("routines/spawn_item_sprite.asm", spawn_item_sprite, $2D)
	JSL spawn_item_sprite
endmacro
!spawn_sprite = 0
macro spawn_sprite()
	%include_once("routines/spawn_sprite.asm", spawn_sprite, $30)
	JSL spawn_sprite
endmacro
!sprite_block_position = 0
macro sprite_block_position()
	%include_once("routines/sprite_block_position.asm", sprite_block_position, $33)
	JSL sprite_block_position
endmacro
!teleport = 0
macro teleport()
	%include_once("routines/teleport.asm", teleport, $36)
	JSL teleport
endmacro
