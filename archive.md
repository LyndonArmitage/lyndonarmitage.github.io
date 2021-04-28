---
layout: page
title: Archives
---

<table>
  <tr>
    <th>Date</th>
    <th>Title</th>
  </tr>
{%- for post in site.posts -%}
  <tr>
    <td>{{ post.date | date_to_string }}</td>
    <td><a href="{{ post.url }}">{{ post.title }}</a></td>
  </tr>
{%- endfor -%}
</table>
