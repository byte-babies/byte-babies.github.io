---
layout: post
title: "SwampCTF 2025: MuddyWater"
date:   2025-03-30
author: wxrth
tags: [writeup]
---


author: @wxrth
## **Challenge Info:**
##### Category: Forensics

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356193892747448350/Screenshot_2025-03-31_at_5.06.02_AM.png?ex=67ebad7c&is=67ea5bfc&hm=12a446886c8db2b7565edc6db6c9f90ffec9f7dc7ee918947c0fd450ac48a9ec&)

## TL;DR:

Opened the `.pcap`, filtered for `STATUS_SUCCESS`, isolated the SMB login stream, extracted the Net-NTLMv2 hash from the `NTLMSSP_AUTH` packet, and cracked it with Hashcat using `rockyou.txt`. Easy.

## The Challenge (Solution):

We’re told a threat actor named MuddyWater was caught bruteforcing a Domain Controller, and we’re given a packet capture to figure out which account successfully logged in.

Opened the `.pcap` in Wireshark and instantly saw tons of `Session Setup Request` packets with `NTLMSSP_AUTH` attempts and it was way too many to go through manually.

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356194176412155904/Screenshot_2025-03-31_at_4.42.25_AM.png?ex=67ebadc0&is=67ea5c40&hm=a67a041899d8eac72c7537c3fb4d169ffe008634bc0d6a21dc82099d4d75f7d5&)
...... the scrolling was nonstop.

#### Step 1 - Filter: 

In `SMB2`, a successful login returns a `STATUS_SUCCESS` response, which is just `0x00000000` in hex. So I used this filter:

```
smb2.nt_status == 0x00000000 && smb2.cmd == 0x01
```

This narrowed it down to a **single packet**: `Frame 72074`. That was the confirmation of a successful login.

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356194452632506489/Screenshot_2025-03-31_at_4.45.50_AM.png?ex=67ebae02&is=67ea5c82&hm=fe85ce8e7bc2b464e03790bc8c76a0c62717b6be302645163552d1a986e6aa47&)

#### Step 2 – Find the TCP stream:

Clicked into `Frame 72074` and checked the TCP stream index:

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356194597772202005/Screenshot_2025-03-31_at_4.47.19_AM.png?ex=67ebae24&is=67ea5ca4&hm=ea0bacef3779a631dbae335c7f22ddb0bb2da319b2b95915bdfa27cf7db36da7&)


Applied this filter to isolate the whole login exchange:

``` 
tcp.stream == 6670
```

This showed the full NTLM login process:

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356194702373814282/Screenshot_2025-03-31_at_4.49.32_AM.png?ex=67ebae3d&is=67ea5cbd&hm=8ad5e3ea7e66bde00194fc0d15be9a5104ef69c4be01e6e82bc4204489b03d6b&)


### Step 3 – Extract the hash:

I saved just this stream to a new `.pcap` and uploaded it to [apackets](https://apackets.com/upload) a very very handy tool for extracting NTLMv2 hashes.

It gave me this full Net-NTLMv2 hash:

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356194789493575751/Pasted_image_20250331045521.png?ex=67ebae52&is=67ea5cd2&hm=d3c4bce1d7f3af49c55b8be26c4ce036034d495a737f7f4b9ba199343a3712df&)

`HACKBACKZIP::DESKTOP-0TNOE4V:d102444d56e078f4:eb1b0afc1eef819c1dccd514c9623201:01010000000000006f233d3d9f9edb01755959535466696d0000000002001e004400450053004b0054004f0050002d00300054004e004f0045003400560001001e004400450053004b0054004f0050002d00300054004e004f0045003400560004001e004400450053004b0054004f0050002d00300054004e004f0045003400560003001e004400450053004b0054004f0050002d00300054004e004f00450034005600070008006f233d3d9f9edb010900280063006900660073002f004400450053004b0054004f0050002d00300054004e004f004500340056000000000000000000`

Saved it into `hash.txt`.

### Step 4 – CRACKKKKKKKK THE HASHHH:

Once the hash was in `hash.txt`, I ran Hashcat in Net-NTLMv2 mode (`-m 5600`) using the classic `rockyou.txt` wordlist:

```bash
hashcat -m 5600 hash.txt rockyou.txt
```

A few seconds later.... 

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356194894753828905/Screenshot_2025-03-31_at_4.57.32_AM.png?ex=67ebae6b&is=67ea5ceb&hm=bcbbf5820845ade7dc77f2d822371b84a09b488512c189f1d637d75c0f840d60&)

boom I cracked it :)

The cracked hash follows the **Net-NTLMv2 format**:

`<username>::<domain>:<server_challenge>:<NTLMv2_response>:<blob>:<password>`

From that, we can clearly see:

```
Username: hackbackzip
Password: pikeplace
```

## 🚩 **Final flag**:  `swampCTF{hackbackzip:pikeplace}`
