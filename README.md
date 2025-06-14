# anal.nvim

## Intro

Anal.nvim is a reminder of **long-time-sitting.**

![preview](./pic.png)

## Install

Using Lazy:


```lua
{
   "waizui/anal.nvim",
},
```

## Usage

In command mode:

**Set reminding interval and display time:**
```txt
:Anal [interval] [display time]
```
interval: time in seconds to wait before showing the message (default: 1800)
display time: time in seconds to display the message (default: 300)

**Set reminding text:**
```txt
:Anal text [whatever you put]
```
for example:
```txt
:Anal text knowledge is power!
```
you will get:

![text](./text.png)

**Switch naughty mode:**
```txt
:Anal naughty
```
when naughty mode is set, reminding window will flash, force you to away from keyboard. 
