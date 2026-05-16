import pty, os, time
pid, fd = pty.fork()
if pid == 0:
    os.execvp("bash", ["bash", "-c", 'export PATH="/var/home/wtg/.local/bin:$PATH"; header_text="\033[0;31mHello World\nLine 2\nLine 3\033[0m"; gum filter --header="$header_text" --height=8 "opt1" "opt2"'])
else:
    time.sleep(1)
    os.write(fd, b"\r")
    time.sleep(0.5)
    print(repr(os.read(fd, 2048).decode()))
