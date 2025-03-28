---
layout: post
title: "BroncoCTF 2025: QR Coded"
date:   2025-02-17
author: Faraz Malik
tags: [writeup, forensics]
---

## Problem

> This one should be really easy. All you have to do is scan a QR code!

Attached is an image called "easy_scan.png", which is exactly as shown.

![](/assets/images/broncoqrcoded/easy_scan.png)

## Steps

Scanning the QR code like the problem statement suggests gives you ```bracco{thi5_1sn7_r34l}```. Not very helpful. I decided to plug the image into [AperiSolve](https://www.aperisolve.com/) to give some more info.

![](/assets/images/broncoqrcoded/aperisolve.png)

I noticed that all layers except the first were identical. This makes sense since the image appeared to be white and black, which are  #ffffff and #000000 respectively. Thus, there was only variation in the least significant bits, which we could see best in the superimposed image in the top left corner. Of course, these variations are impossible to notice on the final image.

One thing to notice is that the colourful superposition actually forms a valid, *but different* QR code. For me, the tell was the clear existence of the 3 large squares and the smaller square near the bottom right (yeah I watched that [Veritasium video](https://www.youtube.com/watch?v=w5ebcowAJD8&pp=ygURcXIgY29kZSBleHBsYWluZWQ%3D)).

![](/assets/images/broncoqrcoded/qr.png)

From there, I just had to convert the colorful image into black and white. This can be done with a simple ImageMagick command.

```
magick qr.png -alpha off -threshold 99% o.png
```

![](/assets/images/broncoqrcoded/o.png)

Scanning the code (or in my case, uploading it to some random QR code decoder site) gives us the flag, ```bronco{th1s_0n3_i5}```.