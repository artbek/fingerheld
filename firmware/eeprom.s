.global _start

_start:

.org 0x010

.word	0b10000000000000000000000000000000
.word	0b01000000000000000000000000000000
.word	0b00100000000000000000000000000000
.word	0b00010000000000000000000000000000
.word	0b00001000000000000000000000000000
.word	0b00010000000000000000000000000000
.word	0b00100000000000000000000000000000
.word	0b01000000000000000000000000000000

.org 0x200

@ Digit 0:
.word 0b01110
.word 0b10001
.word 0b10011
.word 0b10101
.word 0b11001
.word 0b10001
.word 0b01110

@ Digit 1:
.word 0b00100
.word 0b01100
.word 0b00100
.word 0b00100
.word 0b00100
.word 0b00100
.word 0b01110

@ Digit 2:
.word 0b01110
.word 0b10001
.word 0b00001
.word 0b00010
.word 0b00100
.word 0b01000
.word 0b11111

@ Digit 3:
.word 0b11111
.word 0b00010
.word 0b00100
.word 0b00010
.word 0b00001
.word 0b10001
.word 0b01110

@ Digit 4:
.word 0b00010
.word 0b00110
.word 0b01010
.word 0b10010
.word 0b11111
.word 0b00010
.word 0b00010

@ Digit 5:
.word 0b11111
.word 0b10000
.word 0b11110
.word 0b00001
.word 0b00001
.word 0b10001
.word 0b01110

@ Digit 6:
.word 0b00010
.word 0b00100
.word 0b01000
.word 0b11110
.word 0b10001
.word 0b10001
.word 0b01110

@ Digit 7:
.word 0b11111
.word 0b00001
.word 0b00010
.word 0b00100
.word 0b01000
.word 0b01000
.word 0b01000

@ Digit 8:
.word 0b01110
.word 0b10001
.word 0b10001
.word 0b01110
.word 0b10001
.word 0b10001
.word 0b01110

@ Digit 9:
.word 0b01110
.word 0b10001
.word 0b10001
.word 0b01111
.word 0b00010
.word 0b00100
.word 0b01000

