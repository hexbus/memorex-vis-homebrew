# Keyboard and Hand Controller Notes

Input remains one of the most important areas for hardware testing.

## Safe early DOS input

Use polling:

```text
INT 16h AH=01h check key
INT 16h AH=00h read key
```

Avoid:

```text
INT 9h keyboard hooks
keyboard ports 60h/64h
PC/AT scan-code assumptions
```

VISENV includes a hand-controller stub that can later support scripted input events.
