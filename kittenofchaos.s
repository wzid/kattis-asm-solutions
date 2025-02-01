// https://open.kattis.com/problems/kittenofchaos
.data
s_buffer:  .space 500000 // s can be up to 5 * 10^5 characters
t_buffer: .space 500000 // t can be up to 5 * 10^5 characters


.text

.global _main
.align 4
.extern _getchar

_main: 
    mov x19, #0 // s string index/length
    mov x20, #0 // t string index/length
    mov x21, #0 // lets us know if this is the s or t string

read_loop:
    bl _getchar // stores result in x0 (we use w0 though)
    cmp w0, #0xA // newline
    b.eq program_logic
    
    cmp w0, -1 // end of file
    b.eq program_logic

    cmp x21, #1
    b.eq read_t_buffer

    read_s_buffer:
        adrp x1, s_buffer@PAGE
        add x1, x1, s_buffer@PAGEOFF

        strb w0, [x1, x19]
        add x19, x19, #1
    b read_loop

    read_t_buffer:
        adrp x1, t_buffer@PAGE
        add x1, x1, t_buffer@PAGEOFF

        strb w0, [x1, x20]
        add x20, x20, #1
    b read_loop

program_logic:
    add x21, x21, #1
    cmp x21, #2
    b.ne read_loop

    mov x9, #0 // horizonatal bool
    mov x10, #0 // vertical bool
    mov x22, #0 // t_buffer index we use up to the 0x20 value

    adrp x1, t_buffer@PAGE
    add x1, x1, t_buffer@PAGEOFF
    compare_loop:
        ldrb w25, [x1, x22] // load the character into w25

        cmp w25, #0x68 // 'h'
        b.eq set_horizontal
        
        cmp w25, #0x76 // 'v'
        b.eq set_vertical
        
        cmp w25, #0x72 // 'r'
        b.eq set_rotate

        set_horizontal:
            eor x9, x9, #1 // logical negation equivalent
            b continue_compare_loop
        set_vertical:
            eor x10, x10, #1
            b continue_compare_loop
        set_rotate:
            eor x9, x9, #1
            eor x10, x10, #1

        continue_compare_loop:
            add x22, x22, #1
            cmp x22, x20
            b.ne compare_loop
    
    cmp x9, #1
    b.ne do_vertical
    b reverse_string_and_horiz
    
    do_vertical:
    cmp x10, #1
    b.eq apply_vertical
    b print

reverse_string_and_horiz:
    // start and end indexes
    mov x11, #0
    mov x12, x19
    sub x12, x12, #1 // fix off by one error

    adrp x1, s_buffer@PAGE
    add x1, x1, s_buffer@PAGEOFF

    reverse_loop:
        ldrb w24, [x1, x11] // char at start
        ldrb w25, [x1, x12] // char at end

        // swap
        strb w24, [x1, x12]
        strb w25, [x1, x11]

        // move pointers
        add x11, x11, #1
        sub x12, x12, #1

        // check loop condition
        cmp x11, x12
        b.lt reverse_loop

    b apply_horizontal

apply_horizontal:
    mov x11, #0

    adrp x1, s_buffer@PAGE
    add x1, x1, s_buffer@PAGEOFF
    loop_apply_horiz:
        ldrb w24, [x1, x11]

        cmp w24, #0x62 // 'b'
        b.eq swap_b_horiz
        
        cmp w24, #0x64 // 'd'
        b.eq swap_d_horiz
        
        cmp w24, #0x70 // 'p'
        b.eq swap_p_horiz
        
        cmp w24, #0x71 // 'q'
        b.eq swap_q_horiz

        swap_b_horiz:
            mov w24, #0x64 // 'd'
            b store_horiz
        
        swap_d_horiz:
            mov w24, #0x62 // 'b'
            b store_horiz
        
        swap_p_horiz:
            mov w24, #0x71 // 'q'
            b store_horiz
        
        swap_q_horiz:
            mov w24, #0x70 // 'p'

        store_horiz:
        strb w24, [x1, x11]

        add x11, x11, #1
        cmp x11, x19
        b.ne loop_apply_horiz

    b do_vertical

apply_vertical:
    mov x11, #0
    
    adrp x1, s_buffer@PAGE
    add x1, x1, s_buffer@PAGEOFF

    vertical_loop:
        ldrb w24, [x1, x11]

        cmp w24, #0x62 // 'b'
        b.eq swap_b_vert
        
        cmp w24, #0x64 // 'd'
        b.eq swap_d_vert
        
        cmp w24, #0x70 // 'p'
        b.eq swap_p_vert
        
        cmp w24, #0x71 // 'q'
        b.eq swap_q_vert

        swap_b_vert:
            mov w24, #0x70 // 'p'
            b store_vert
        
        swap_d_vert:
            mov w24, #0x71 // 'q'
            b store_vert
        
        swap_p_vert:
            mov w24, #0x62 // 'b'
            b store_vert
        
        swap_q_vert:
            mov w24, #0x64 // 'd'

        store_vert:
        strb w24, [x1, x11]

        add x11, x11, #1
        cmp x11, x19
        b.ne vertical_loop
    
    b print


print:
    mov x0, #1
    adrp x1, s_buffer@PAGE
    add x1, x1, s_buffer@PAGEOFF
    mov x2, x19
    mov x16, #4
    svc #0x80
    
exit:
mov     x0, #0          // Return value
mov     x16, #1         // Exit syscall
svc     #0x80