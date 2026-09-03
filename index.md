---
layout: default
# `title` must match site.title exactly. jekyll-seo-tag only falls back to
# "<site.title> | <site.description>" when the two are equal; give the page any
# other title and it emits the doubled "<page title> | ARQ-COMP" instead.
#
# Leaving `title` out does not work: jekyll-titles-from-headings, which GitHub
# Pages enables by default, would lift the "ARQ-COMP 2027" heading below into
# page.title and reintroduce the doubling.
title: ARQ-COMP
#
# Important Dates lists only milestones that have actually been settled, so a
# reader can trust every row. Add the later ones (submission deadlines, results)
# as each date is fixed rather than carrying them as "To be announced".
#
# Dates are written day-first and unabbreviated -- "30 September 2026" -- in
# both the table and the News list, so the two read the same.
# Add news items to the top of the News list, newest first.
---

# ARQ-COMP 2027

The Competition on Automated Reasoning for Quantum.

## Important Dates

{% comment %}
  Written out as HTML rather than as a Markdown table for one reason: kramdown
  cannot put attributes on individual cells, and the header cells need
  scope="col" so a screen reader can associate each date with its milestone.
  To add a milestone, copy the <tr> block.
{% endcomment %}
<table>
  <thead>
    <tr>
      <th scope="col">Milestone</th>
      <th scope="col">Date</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="{{ '/submit-benchmarks/' | relative_url }}">Call for problems/<wbr>benchmarks/<wbr>comments</a></td>
      <td>30 September 2026</td>
    </tr>
  </tbody>
</table>

## Communication

Announcements and discussion happen on the
[ARQ-COMP mailing list](https://groups.google.com/g/arq-comp) — subscribe there
to follow the competition.

## News

- **1 September 2026** — Web site running.

## Organizers

- [Johannes K. Fichte](https://liu.se/en/employee/johfi52)
- [Ondřej Lengál](https://ondrik.github.io/)
- ...
