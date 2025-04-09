---
layout: post
title: "JerseyCTF 2025: Encoded-Deception"
date:   2025-03-30
author: me
tags: [writeup, web]
---


author: @wxrth
## **Challenge Info:**
##### Category: Web

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356229190277402775/Screenshot_2025-03-31_at_7.28.21_AM.png?ex=67ebce5c&is=67ea7cdc&hm=e2d7ed5b3fb087558bc05836aca4b748cc7002d2319fcb01b53746b30e87db82&)
## TL;DR:

Poked around the website of a shady cyber-investigation agency, checked their JavaScript, and found a base64-encoded "Part 1" of a flag. Then sniffed out "Part 2" hidden in a response header from a PHP file. Decoded both parts, stitched 'em together and boom got the full flag. 

## The Challenge (Solution): 

The challenge gave us this website 

```http
http://encoded-deception.aws.jerseyctf.com/
```

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356229189077827796/Screenshot_2025-03-31_at_7.09.06_AM.png?ex=67ebce5c&is=67ea7cdc&hm=af271a0fe30d7b22753237ddc842cc970eba36bb0fda385bda7d4e3876c06d2d&)

Nothing seemed interactive on the surface. But the hint?

> “Sometimes, secrets are buried in scripts…”

So I cracked open **DevTools** and went hunting.

#### Step 1 – Exploring:

Inside the **Sources** tab, under `/assets/`, there was a single JS file: `casefiles.js`. 

```js
function generateRandomHash(length) {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}

const hash1 = generateRandomHash(16);
const hash2 = generateRandomHash(24);

console.log("Initializing Black Hat Investigations system...");
console.log("User session ID:", hash1);
console.log("Verification key:", hash2);

const secretMessage = "UGFydCAxOiBqY3RmdntteXN0M3J5"; 
console.log("Nothing to see here... or is there?");

const fakeData = [
    "aGVsbG8gd29ybGQ=", 
    "ZGF0YXN0cmVhbQ==", 
    "U29tZXRoaW5nIHN1c3BpY2lvdXM="
];

function decodeFakeData(index) {
    return atob(fakeData[index]);
}

console.log("Processing encrypted logs...");
setTimeout(() => {
    console.log("Log entry:", decodeFakeData(Math.floor(Math.random() * fakeData.length)));
}, 2000);

async function fetchDummyData() {
    return fetch('/info.php');
}

fetchDummyData().then(response => console.log(response));
```

That `secretMessage` variable caught my eye:

```js
const secretMessage = "UGFydCAxOiBqY3RmdntteXN0M3J5";
```

Looks like **base64** so I copied it, opened up [dcode](https://www.dcode.fr/base-64-encoding), to check it out.

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356229189354655794/Screenshot_2025-03-31_at_7.14.33_AM.png?ex=67ebce5c&is=67ea7cdc&hm=cd2f1387c8c09171d10dd132098b571fd16aae0513a3c37088ba4eeb60787c2b&)

Sure enough, the output gave me:

```
Part 1: jctf{myst3ry
```

First half of the flag secured. Time to track down the second half.

Looking back at the script, I saw this:

```js
fetch('/info.php');
```

Which meant there might be something interesting in the network traffic...

#### Step 3 – Inspecting `/info.php`:

I reloaded the page with **DevTools → Network** open, clicked on `info.php`, and sure enough in the **Response Headers** I found this:

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356229189690331137/Screenshot_2025-03-31_at_7.18.17_AM.png?ex=67ebce5c&is=67ea7cdc&hm=32b43cc9a17e938093bb96ed567b744d166a637c29eedabfba6d1e69a65c95ba&)

```
HTTP/1.1 200 OK
Date: Mon, 31 Mar 2025 10:58:01 GMT
Server: Apache/2.4.62 (Amazon Linux)
Important: UGFydCAyOiBfMHAzcjR0MTBufQ==
Keep-Alive: timeout=5, max=99
Connection: Keep-Alive
Transfer-Encoding: chunked
Content-Type: text/plain;charset=UTF-8
```

Theres a header named `"Important"`

```
Important: UGFydCAyOiBfMHAzcjR0MTBuf
```

It looked like another base64 string just like earlier. So I copied it, headed back to [dcode.fr](https://www.dcode.fr/base-64-encoding), and dropped it in.

![](https://cdn.discordapp.com/attachments/1250994621438496849/1356229189992185989/Screenshot_2025-03-31_at_7.23.11_AM.png?ex=67ebce5c&is=67ea7cdc&hm=da5ed7eed9d722c5b70152368082febd43009208b7fd6fe68da60f9ffafd6ddc&)

Output:

```
Part 2: _0p3r4t10n}
```

Boom, second half of the flag successfully uncovered.

#### Step 4: Combineeeeeee!

Now with both pieces in hand:

- **Part 1:** `jctf{myst3ry`
- **Part 2:** `_0p3r4t10n}`

## 🚩 **Final flag**:  `jctf{myst3ry_0p3r4t10n}`




