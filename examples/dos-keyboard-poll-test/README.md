# DOS Keyboard Poll Test

Goal: use polling-style input instead of hooking INT 9h.

Prefer:

```text
INT 16h AH=01h  check key
INT 16h AH=00h  read key
```

Avoid:

```text
installing INT 9h handlers
reading ports 60h/64h directly
```
