# Save-It / CyberCard Notes

Save-It / CyberCard storage should not be modeled as a normal DOS FAT drive.

VISENV models it as service-backed persistent storage:

```text
visenv/src/cybercard_stub.py
```

Current stub behavior:

```text
card present/absent
configurable size
backing file
read/write service calls
```
