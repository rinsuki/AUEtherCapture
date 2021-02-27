import subprocess
import sys
import os
import shutil

r = subprocess.run(["dumpbin", "/DEPENDENTS", sys.argv[1]], stdout=subprocess.PIPE)
dlls = []
state = 0

for line in r.stdout.decode("UTF-8").split("\r\n"):
    if line == '':
        if state == 0:
            continue
        elif state == 1:
            state = 2
        elif state == 2:
            break
    elif state == 2:
        if line[0:4] == "    ":
            dlls.append(line[4:])
        else:
            print("found unknown line", line)
            exit(1)
    elif state == 0 and line == '  Image has the following dependencies:':
        state = 1

paths = os.getenv("PATH").split(";")
dllpaths = []
for dll in dlls:
    found = False
    for path in paths:
        dllpath = os.path.join(path, dll)
        if os.path.exists(dllpath):
            dllpaths.append(dllpath)
            found = True
            break
    if not found:
        print("WARNING: Can't find ", dll)

for dllpath in dllpaths:
    if dllpath.startswith(r"C:\Library"):
        shutil.copy2(dllpath, os.path.dirname(sys.argv[1]))
        print("Copied", dllpath)
