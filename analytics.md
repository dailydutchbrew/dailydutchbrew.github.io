---
layout: page
title: Analytics
permalink: /analytics/
---

<h2>Current Week Record:</h2>
<p>(Week starts on Sundays)</p>
<p>{{ site.data.totals.week_w }} - {{ site.data.totals.week_l }} - {{ site.data.totals.week_p }}</p>
<h2>Monthly Record:</h2>
{%- for month_record in site.data.totals.monthly_mls reversed -%}
<p>{{ month_record.month }}: {{ month_record.record}}</p>
{%- endfor -%}
