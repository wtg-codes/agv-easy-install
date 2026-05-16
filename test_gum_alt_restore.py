import pty, os, time

pid, fd = pty.fork()
if pid == 0:
    # Print banner
    print("BANNER ROW 1")
    print("BANNER ROW 2")
    # Run gum filter (which uses alternate screen without --height)
    os.execvp("gum", ["gum", "filter", "--header=FILTER HEADER", "opt1", "opt2"])
else:
    time.sleep(1)
    os.write(fd, b"\r") # submit
    time.sleep(0.5)
    output = os.read(fd, 2048).decode()
    print("OUTPUT TRACE:")
    print(repr(output))
