import subprocess
import sys
import os
import shutil

copied_dlls = []

def find_dll_and_copy(pe_binary: str, copy_dest: str):
    r = subprocess.run(["dumpbin", "/DEPENDENTS", pe_binary], stdout=subprocess.PIPE)
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
        if dllpath.startswith(r"C:\Library") and dllpath not in copied_dlls:
            copied_dlls.append(dllpath)
            shutil.copy2(dllpath, copy_dest)
            print("Copied", dllpath)
            # swiftCore.dll → ICU とかの依存をコピーするために再帰で探す必要がある
            find_dll_and_copy(dllpath, copy_dest)
        else:
            print("System", dllpath)

find_dll_and_copy(sys.argv[1], os.path.dirname(sys.argv[1]))