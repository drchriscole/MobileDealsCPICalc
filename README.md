---
editor_options: 
  markdown: 
    wrap: 72
---

# Mobile Deals CPI Calculator

It's Christmas 2022 and browsing through various mobile deals it seemed
that many were very cheap even for iphones which are almost never
subsidised nor discounted. Some of the 24-month deals look very
attractive over buying outright. But is there an expensive sting in the
tail?

For example, an iphone 14 128GB is £849 outright.

IDmobile's cheapest deal for the same model is £37.99 pm (£99 upfront
cost) which is £1010 over the 24 months. Factoring in the "value" of the
25GB mobile plan in the deal worth about £8 pm means the cost of the
phone is actually £818 (£1010 - (8\*24).

Sounds like a great deal.

However, I've noticed that the annual increases that networks are
allowed to charge without triggering no-fee exit clauses apply to the
*whole deal* which means it applies to the service cost *and* phone
bundle. With the current high rates of inflation means that over two
years you may end up paying significantly more for your phone.

Cost could actually be:

Dec 22 - Mar 23 = 37.99 pm\
Apr 23 - Mar 24 = 43.27 pm (CPI 10% + 3.9%) [^1]\
Apr 24 - Nov 24 = 46.26 pm (CPI 3% + 3.9%)

[^1]: CPI predictions are from NIESR:
    <https://www.niesr.ac.uk/blog/inflation-set-fall-early-2023>

Sum total = (4\*37.99) + (12\*43.27) + (8\*46.26) + 99 = £1140

£130 more than someone might have calculated. I'll certainly be avoiding
these deals.

Sneaky tactics? Are the telcos doing these deals knowing full well
they're not as cheap as they seem? [The
Guardian](https://www.theguardian.com/technology/2022/dec/04/labour-calls-for-crackdown-on-rip-off-christmas-broadband-and-mobile-ads)
have reported on this as well.

It also doesn't seem to be a coincidence that there are no 12 or 18
month deals anymore on the main networks.

## Shiny App

An interactive shiny calculator is available in the `MobileCPICalc/`
subfolder.
