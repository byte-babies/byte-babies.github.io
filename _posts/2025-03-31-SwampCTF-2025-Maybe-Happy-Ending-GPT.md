---
layout: post
title: "SwampCTF 2025: Maybe Happy Ending GPT"
date:   2025-03-31
author: yoshixi
tags: [writeup]
---


author: @yoshixi
## **Challenge Info:**
##### Category: Web, LLM

## Challenge Resources

![maybehappyending](https://digitalyoshixi.github.io/ctfs/swampctf2025/maybehappy.webp)

[Web URL](http://chals.swampctf.com:50207/)

[Download](https://ctf.swampctf.com/files/68f09c26e413cc219c7711c6e945d8fc/MaybeHappyEndingGPT.zip?token=eyJ1c2VyX2lkIjoxOTEsInRlYW1faWQiOjEwOCwiZmlsZV9pZCI6Mzd9.Z-oTmg.qLXXXrIORiDeBtnveM7ITCvmXr0)

### Solution

Search for references of `flag`

![references](https://digitalyoshixi.github.io/ctfs/swampctf2025/references.webp)

We see that there is a hint here, and that it is using eval()

![eval](https://digitalyoshixi.github.io/ctfs/swampctf2025/eval.webp)

It is reading the LLM's response and then evaluating it and returning the eval's output as a response

![ls](https://digitalyoshixi.github.io/ctfs/swampctf2025/ls.webp)

![gptflag](https://digitalyoshixi.github.io/ctfs/swampctf2025/gptflag.webp)muddywater