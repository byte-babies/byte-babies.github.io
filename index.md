---
layout: default
title: Homepage
---

<div class="flavor">
    <img src="/assets/images/shoutbaby.png" class="logo">
    <p>
        we:
        <br>
        <ul>
            <li>conquer (with pwn tools)</li>
            <li>disseminate (shellcode across the system)</li>
            <li>corrupt (process memory sometimes)</li>
            <li>mutate (protected data)</li>
            <li>have a jolly good time</li>
        </ul>
    </p>
</div>

### Recent CTFs:

<table border="1">
    <tr>
        <th>CTF</th>
        <th>Points</th>
        <th>Placement</th>
        <th>Rating Points</th>
    </tr>
    {% assign filtered_ctfs = site.data.ctftime_data | where_exp: "ctf", "ctf.rating > 3" %}
    {% for event in filtered_ctfs limit:7 %}
        <tr>
            <td>{{ event.title }}</td>
            <td>{{ event.points }}</td>
            <td>{{ event.place }} out of {{ event.total_teams }}</td>
            <td>{{ event.rating | times: 1000.0 | round | divided_by: 1000.0 }}</td>
        </tr>
    {% endfor %}
</table>

[CTFTime](https://ctftime.org/team/280084)

[Github](https://github.com/byte-babies)

[Discord](https://discord.gg/DwXKnG8FNC)
