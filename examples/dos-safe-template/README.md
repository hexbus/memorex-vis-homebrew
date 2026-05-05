# DOS Safe Template

A minimal VIS-friendly DOS program should use:

```text
INT 10h graphics mode set
INT 16h keyboard polling
INT 21h for file/exit behavior
```

Avoid:

```text
INT 9h hooks
keyboard ports
text-mode dependency
Sound Blaster-only audio
```
