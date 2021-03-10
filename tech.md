---
layout: page
title: Technical Knowledge
---

This is a non-exhaustive list of the technologies I have used in the past
and my perceived familiarity with them.

Some I have used professionally whilst others I have only some hobbyist
experience with. I have tried to take into account my skills getting rusty
since using them as well.  

{% for category in site.data.tech %}
  {%- assign category_name = category[0] -%}
  {%- assign category_data = category[1] -%}
  <h2>{{ category_name }}</h2>
  <table>
  {%- for entry in category_data -%}
    <tr>
      <th>{{ entry[0]}}</th>
      <td><progress max="100" value="{{ entry[1] }}"></progress></td>
    </tr>
  {%- endfor -%}
  </table>
{%- endfor -%}

