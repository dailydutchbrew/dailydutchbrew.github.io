---
layout: page
title: Analytics
permalink: /analytics/
---

<h2>Current Week Record:</h2>
<p>(Week starts on Sundays)</p>
<p>{{ site.data.totals.week_w }} - {{ site.data.totals.week_l }} - {{ site.data.totals.week_p }}</p>
<h2>Record by Sport:</h2>
<p>NBA: {{ site.data.totals.nba_record }} ({{ site.data.totals.nba_record_win_pct }})</p>
<p>NHL: {{ site.data.totals.nhl_record }} ({{ site.data.totals.nhl_record_win_pct }})</p>
<p>NBA: {{ site.data.totals.mlb_record }} ({{ site.data.totals.mlb_record_win_pct }})</p>
<p>NFL: {{ site.data.totals.nfl_record }} ({{ site.data.totals.nfl_record_win_pct }})</p>
<p>MMA: {{ site.data.totals.mma_record }} ({{ site.data.totals.mma_record_win_pct }})</p>
<h2>Monthly Record:</h2>
{%- for month_record in site.data.totals.monthly_mls reversed -%}
<p>{{ month_record.month }}: {{ month_record.record}}</p>
{%- endfor -%}
