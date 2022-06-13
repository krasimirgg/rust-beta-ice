# rust-beta-ice

Example of a rustc ICE with latest beta that uses a freshly built stdlib.

To repro, `./run-in-docker.sh` which sets up a custom stdlib build and then tries to build a chain of crates leading up to an ICE:

https://gist.github.com/krasimirgg/69af6c35ebbe90d0d1d080831e97ee4c
```
thread 'rustc' panicked at 'invalid enum variant tag while decoding `MacroKind`, expected 0..3'
```
