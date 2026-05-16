import pty, os, time

pid, fd = pty.fork()
if pid == 0:
    os.execvp("gum", ["gum", "filter", "--height=8", "--header=MY HEADER", "opt1", "opt2"])
else:
    time.sleep(1)
    os.write(fd, b"\r") # send Enter
    time.sleep(0.5)
    output = os.read(fd, 1024).decode()
    print("OUTPUT AFTER EXIT:")
    print(repr(output))
