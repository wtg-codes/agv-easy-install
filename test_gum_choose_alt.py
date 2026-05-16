import pty, os, time

pid, fd = pty.fork()
if pid == 0:
    os.execvp("gum", ["gum", "choose", "opt1", "opt2"])
else:
    time.sleep(1)
    os.write(fd, b"\r")
    time.sleep(0.5)
    output = os.read(fd, 1024).decode()
    print("OUTPUT AFTER EXIT:")
    print(repr(output))
