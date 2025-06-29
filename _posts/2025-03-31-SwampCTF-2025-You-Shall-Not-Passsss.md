---
layout: post
title: "SwampCTF 2025: You Shall Not Passsss"
author: yoshixi
tags: [writeup, rev]
---


author: @yoshixi
## **Challenge Info:**
##### Category: Rev

## Challenge Resources

![youshalnotpass](https://digitalyoshixi.github.io/ctfs/swampctf2025/youshalnotpass.webp)
[Download](https://ctf.swampctf.com/files/10ed11c19ea792d32db42fe63d217274/chal?token=eyJ1c2VyX2lkIjoxOTEsInRlYW1faWQiOjEwOCwiZmlsZV9pZCI6OX0.Z-oU4Q.PAkwNhds6tYYtyuL1FBr838q7Fw)

### Solution

We first decompile with binary ninja

In the main function, We allocate 3 pointers and 1 variable, change a variable until its non-zero, do a lot more assignments to variables from constants loaded within memory, and perform a hashing function for each of them (there are like 20 of thes variables). Another loop of a pointer, and then we run the 2nd function
![libcmain](https://digitalyoshixi.github.io/ctfs/swampctf2025/libcmain.webp)
![3alloca](https://digitalyoshixi.github.io/ctfs/swampctf2025/3alloca.webp)
![nonzero](https://digitalyoshixi.github.io/ctfs/swampctf2025/nonzero.webp)
![lastassgn](https://digitalyoshixi.github.io/ctfs/swampctf2025/lastassgn.webp)
The second function is a lot more interesting. It constructs a list, with the first element as a function. Then, it calls that function.
![2ndfunc](https://digitalyoshixi.github.io/ctfs/swampctf2025/2ndfunc.webp)

### Debugging
So, the function data is dynamicaly loaded. We debug to see whats going on.
- Enter libc_start_main
- Continue until we enter main which is here:
![gdb1](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb1.webp)
- Step into that call, then keep moving until we call rax. Our entry is at `0x5555555550c0`. This is what it looks like:
![gdb2](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb2.webp)
- It iterates through a loop, and it runs in it for 20 times.
- Afterwards, it gradually pushes the word `Incorrect\n` onto the memory locations
![gdb3](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb3.webp)
- Then, it writes `Correct!\n` to the memory space afterwards
![gdb4](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb4.webp)
- Afterwards, save some data to the heap
![gdb5](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb5.webp)
- Enter a loop that repeats 181 times,
- Write the data, then jump into the next call. 
![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb6.webp)
- Then, it tries to mmap, and it will jump out if it fails.
- It will then move some string contents into registers
![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb7.webp)
- Moves some more things around
- Moves in some constants, then calls rbp 
![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb8.webp)
- Inside rbp: string constants and data is being loaded
![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb9.webp)
- Enters a loop that runs 38 times
![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb10.webp)
- It should have a conditional move that occurs when dil is equal to r8b
![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb11.webp)
**This is the key.**
- Initially, before the start of the loop, rbx is `Correct!\n`
![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb12.webp)
- After the loop, if esi is 0, then the value at r14 (which is `Incorrect`) is moved into rbx, then it prints rbx.
![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb13.webp)
	- ![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb14.webp)
	- ![gdb6](https://digitalyoshixi.github.io/ctfs/swampctf2025/gdb15.webp)
	- If this comparison is not equal, then we will have to cmov
	- so, this comparison must be equal all 36 times
- Setting the first character to `s` passes the first check, so we know that it is decoding now character by character. Also, changing characters does not modify the `r8b` values, so these are constant.
- Now, we know that it loads the character into `dil`, xors it with `al` and compares it to be `r8b`. So, we should be able to find the character from the expected `r8b` values and `al` values.
- I have a script to help me calculate the next character, since I did not want to reverse engineer the encryption process

```python
def find_a(b_hex, c_hex):
  b_int = int(b_hex, 16)  # Convert b from hex to integer
  c_int = int(c_hex, 16)  # Convert c from hex to integer
  a_int = c_int ^ b_int  # Perform the XOR operation
  a_hex = hex(a_int)  # Convert a back to hexadecimal
  return a_hex

b_decimal = int(input('b_decimal: '))
b_hex = hex(b_decimal & 0xFF) #ensure 8 bit representation.
c_hex = input("c_hex: ")

result_hex = int(find_a(b_hex, c_hex), 16)
print(f"a = {result_hex}, chr(a) = {chr(result_hex)}")
```
Kept on running the script until i got the flag. 

<iframe width="800" height="400" src="https://digitalyoshixi.github.io/ctfs/swampctf2025/flaginputs.mp4" frameborder="0" allowfullscreen></iframe>


## Flag is : `swampCTF{531F_L0AD1NG_T0TALLY_RUL3Z}`