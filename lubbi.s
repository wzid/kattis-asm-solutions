.data
buffer:  .space 1               // We only need 1 byte for a single character

.text
.global _main
.align 4
.extern _getchar
_main: 
    // reads a single character
    bl      _getchar        // Result will be in x0

    // Store the character in our buffer
    adrp x1, buffer@PAGE
    add x1, x1, buffer@PAGEOFF
    strb w0, [x1]

    // Print the character
    mov     x0, 1          // stdout
    mov     x2, 1          // Length (1 character)
    mov     x16, 4         // Write syscall
    svc     128

exit:
mov     x0, 0          // Return value
mov     x16, 1         // Exit syscall
svc     128