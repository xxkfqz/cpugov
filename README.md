# cpugov

Simple perl script to manage CPU governors on *NIX systems

## Usage:

```bash
$ cpugov.pl               # Print available governors
Available governors:
 [0]    conservative
 [1]    ondemand
 [2]    userspace
 [3]    powersave
 [4] -> performance
 [5]    schedutil
$ cpugov.pl ondemand      # Set governor by name
Switching from 'performance' to 'ondemand'
$ cpugov.pl 5             # Set governor by index
Switching from 'ondemand' to 'schedutil'
```
