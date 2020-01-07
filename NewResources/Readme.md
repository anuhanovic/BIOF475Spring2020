- http://deepdreamgenerator.com
- http://pandorabots.com/mitsuku
- http://captionbot.ai
- http://affinelayer.com/pixsrv
- http://experiments.madewithgoogle.com
- http://tens.rs/demos/fast-neural-style
- http://playground.tensorflow.org

## New Macs - Catalina
## list details alias
MacOS switched from BASH to ZSH (Z shell) in Catalina version of the OS, so to implement 'll' alias found on Linux *for all users* (needs sudo):
```
$sudo nano /etc/zprofile 
```
and add:
```
alias ll='ls -laG'
```
For just one user (yourself) edit the `~/.zshrc` file:
```
$sudo nano ~/.zshrc
```
### ZSH history
#### full history
- Z shell also by default lists only last 16 commands - to get the entire history use `history 1`.
- To fix this madness add the following alias to either `~/.zshrc` or `/etc/zprofile` (current or all users):
```
alias history='history 1'
```
#### move over bash history (pre-pend)
https://gist.github.com/muendelezaji/c14722ab66b505a49861b8a74e52b274
