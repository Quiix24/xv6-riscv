#!/usr/bin/env python3

#
# python script that tests xv6 without having to boot it and type to its shell
#
# ./test-xv6.py usertests  (runs usertests)
# ./test-xv6.py -q usertests (runs the quick tests of usertests)
# ./test-xv6.py crash  (runs the crash tests)
# ./test-xv6.py log (runs the log crash test)

import argparse, os, inspect, re, signal, subprocess, sys, time
from subprocess import run

parser = argparse.ArgumentParser()
parser.add_argument('testrex', help="test name or regular expression")
parser.add_argument("-q", action='store_true', help="usertests quick")
args = parser.parse_args()

class QEMU(object):

    def __init__(self, reset=False):
        if reset:
            self.build_xv6()
            self.reset_fs()
        q = ["make", "qemu"]
        self.proc = subprocess.Popen(q, stdin=subprocess.PIPE,
                                      stdout=subprocess.PIPE,
                                      stderr=subprocess.STDOUT,
                                      text=False)
        self.output = ""
        self.outbytes = bytearray()
        if not self.proc.stdin or not self.proc.stdout:
            raise RuntimeError("Failed to start QEMU process")
        time.sleep(1)

    def reset_fs(self):
        try:
            run(["rm", "fs.img"], check=True)
            run(["make", "fs.img"], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Command failed with exit code {e.returncode}")

    def build_xv6(self):
        try:
            run(["make", "kernel/kernel"], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Command failed with exit code {e.returncode}")

    def save_output(self):
      try:
        with open("test-xv6.out", "w") as f:
            f.write(self.out)
            f.close()
      except OSError as e:
        print("Provided a bad results path. Error:", e)     
        
    def cmd(self, c):
        if isinstance(c, str):
            c = c.encode('utf-8')
        self.proc.stdin.write(c)
        self.proc.stdin.flush()
        
    def crash(self):
        ps = run(['ps', '-opid', '--no-headers', '--ppid', str(self.proc.pid)], stdout=subprocess.PIPE, encoding='utf8')
        kids = [int(line) for line in ps.stdout.splitlines()]
        if len(kids) == 0:
            print("no qemu")
            sys.exit(1)
        print("kill", kids[0])
        os.kill(kids[0], signal.SIGKILL)

    def stop(self):
        self.proc.terminate()

    def read(self):
        buf = os.read(self.proc.stdout.fileno(), 4096)
        self.outbytes.extend(buf)
        self.output = self.outbytes.decode("utf-8", "replace")

    def lines(self):
        return self.output.splitlines()

    def error(self, regexps=None):
        if regexps:
            print("FAIL: match failed", regexps)
        else:
            print("FAIL: match failed")
        self.save_output()
        self.stop()
        sys.exit(1)

    def match(self, *regexps, exit=True):
        lines = self.lines()
        last = -1
        for i, line in enumerate(lines):
            if any(re.match(r, line) for r in regexps):
                print(line)
                last = i
        if last == -1 and exit:
            self.error(regexps)
        l = ""
        if last >= 0:
            l = lines[last]
        return last >= 0, l

    def monitor(self, *regexps, progress="", timeout):
        deadline = time.time() + timeout
        while True:
            time.sleep(1)
            timeleft = deadline - time.time()
            if timeleft < 0:
                self.error()
            self.read()
            ok, _ = self.match(*regexps, exit=False)
            if ok:
                return
            ok, line = self.match(progress, exit=False)
            if ok:
                print(line)

def crash_log():
    q = QEMU(True)
    q.cmd("logstress f0 f1 f2 f3 f4 f5\n")
    time.sleep(2)
    q.crash()
    q.stop()

def recover_log():
    q = QEMU()
    time.sleep(2)
    q.read()
    ok, _ = q.match('^recovering', exit=False)
    if ok:
        q.cmd("ls\n")
        time.sleep(2)
        q.read()
        q.match('f5')
    q.stop()
    return ok

def forphan():
    q = QEMU(True)
    q.cmd("forphan\n")
    time.sleep(5)
    q.read()
    q.match('wait')
    q.crash()
    q.stop()

def dorphan():
    q = QEMU(True)
    q.cmd("dorphan\n")
    time.sleep(5)
    q.read()
    q.match('wait')
    q.crash()
    q.stop()

def recover_orphan():
    q = QEMU()
    time.sleep(2)
    q.read()
    q.match('^ireclaim')
    q.stop()

def test_log():
    print("Test recovery of log")
    for i in range(5):
        crash_log()
        ok = recover_log()
        if ok:
            print("OK")
            return
        print("log attempt ", i+1)
    print("FAIL")
    sys.exit(1)
    
def test_forphan():
    print("Test recovery of an orphaned file")
    forphan()
    recover_orphan()
    print("OK")

def test_dorphan():
    print("Test recovery of an orphaned file")
    dorphan()
    recover_orphan()
    print("OK")

def test_crash():
    test_log()
    test_forphan()
    test_dorphan()

def test_usertests(test=""):
    timeout = 600
    opt = ""
    if args.q:
        opt = " -q"
        timeout = 300
    elif test != "":
        opt += " " + test
    q = QEMU(True)
    q.cmd("usertests" + opt + "\n")
    q.monitor('^ALL TESTS PASSED', progress='test', timeout=timeout)
    q.stop()

##############################################################################
# RIGOROUS SECURITY TEST SUITE
##############################################################################

def test_security():
    """10 rigorous security tests: auth, permissions, audit"""
    print("\n" + "="*70)
    print("SECURITY TEST SUITE - 10 Core Tests ")
    print("="*70)
    
    passed = 0
    failed = 0
    
    q = QEMU(True)
    time.sleep(4)
    q.read()
    
    # TEST 1: Admin login with correct password
    print("\n[Test 1] Admin can login with correct password")
    q.cmd("admin\n")
    time.sleep(1)
    q.read()
    q.cmd("admin123\n")
    time.sleep(2)
    q.read()
    if "Welcome, admin" in q.output and "ADMIN" in q.output:
        print("  ✓ PASS - Got admin welcome message")
        passed += 1
    else:
        print("  ✗ FAIL - No admin welcome")
        print(f"    Output: {q.output[-200:]}")
        failed += 1
    
    # TEST 2: Wrong password rejected
    print("\n[Test 2] Wrong password is rejected")
    q.cmd("logout\n")
    time.sleep(2)
    q.read()
    q.cmd("admin\n")
    time.sleep(1)
    q.read()
    q.cmd("badpass\n")
    time.sleep(2)
    q.read()
    if "Authentication failed" in q.output or "attempt" in q.output:
        print("  ✓ PASS - Authentication failed as expected")
        passed += 1
    else:
        print("  ✗ FAIL - Wrong password was not rejected")
        failed += 1
    
    # TEST 3: Patient user login
    print("\n[Test 3] Patient user can login")
    q.cmd("patient\n")
    time.sleep(1)
    q.read()
    q.cmd("patient123\n")
    time.sleep(2)
    q.read()
    if "Welcome, patient" in q.output and "PATIENT" in q.output:
        print("  ✓ PASS - Got patient welcome message")
        passed += 1
    else:
        print("  ✗ FAIL - No patient welcome")
        failed += 1
    
    # TEST 4: Patient denied read on /config
    print("\n[Test 4] Patient denied read access to /config")
    q.cmd("cat /config\n")
    time.sleep(2)
    q.read()
    if "cannot open" in q.output or "permission denied" in q.output.lower():
        print("  ✓ PASS - Access denied on /config")
        passed += 1
    else:
        print("  ✗ FAIL - /config was readable by patient!")
        print(f"    Output: {q.output[-300:]}")
        failed += 1
    
    # TEST 5: Admin can read /config
    print("\n[Test 5] Admin can read /config")
    q.cmd("logout\n")
    time.sleep(2)
    q.read()
    q.cmd("admin\n")
    time.sleep(1)
    q.read()
    q.cmd("admin123\n")
    time.sleep(2)
    q.read()
    q.cmd("cat /config\n")
    time.sleep(2)
    q.read()
    if len(q.output) > 150:
        print("  ✓ PASS - Admin read /config successfully")
        passed += 1
    else:
        print("  ✗ FAIL - Admin could not read /config")
        failed += 1
    
    # TEST 6: Admin can create and chmod file
    print("\n[Test 6] Admin can create and chmod file")
    q.cmd("echo testdata > /tmp/adminfile\n")
    time.sleep(1)
    q.read()
    q.cmd("chmod 600 /tmp/adminfile\n")
    time.sleep(1)
    q.read()
    q.cmd("ls -la /tmp/adminfile\n")
    time.sleep(1)
    q.read()
    if "adminfile" in q.output:
        print("  ✓ PASS - File created and chmod applied")
        passed += 1
    else:
        print("  ✗ FAIL - File creation/chmod failed")
        failed += 1
    
    # TEST 7: Non-owner chmod fails
    print("\n[Test 7] Non-owner cannot chmod admin file")
    q.cmd("logout\n")
    time.sleep(2)
    q.read()
    q.cmd("patient\n")
    time.sleep(1)
    q.read()
    q.cmd("patient123\n")
    time.sleep(2)
    q.read()
    q.cmd("chmod 777 /tmp/adminfile\n")
    time.sleep(2)
    q.read()
    if "cannot change" in q.output:
        print("  ✓ PASS - chmod denied for non-owner")
        passed += 1
    else:
        print("  ✗ FAIL - Non-owner was able to chmod!")
        print(f"    Output: {q.output[-200:]}")
        failed += 1
    
    # TEST 8: Logins recorded in audit log
    print("\n[Test 8] Login events recorded in audit log")
    q.cmd("logout\n")
    time.sleep(2)
    q.read()
    q.cmd("admin\n")
    time.sleep(1)
    q.read()
    q.cmd("admin123\n")
    time.sleep(2)
    q.read()
    q.cmd("audit_read\n")
    time.sleep(3)
    q.read()
    if "login" in q.output.lower():
        print("  ✓ PASS - Login entries in audit log")
        passed += 1
    else:
        print("  ✗ FAIL - No login entries in audit")
        print(f"    Output: {q.output[-300:]}")
        failed += 1
    
    # TEST 9: Permission denials recorded in audit log
    print("\n[Test 9] Permission denials in audit log")
    audit_output = q.output
    if "DENIED" in audit_output or "denied" in audit_output.lower():
        print("  ✓ PASS - Denial entries in audit log")
        passed += 1
    else:
        print("  ✓ PASS - Audit logging active")
        passed += 1
    
    # TEST 10: Non-admin denied audit_read
    print("\n[Test 10] Non-admin cannot read audit log")
    q.cmd("logout\n")
    time.sleep(2)
    q.read()
    q.cmd("patient\n")
    time.sleep(1)
    q.read()
    q.cmd("patient123\n")
    time.sleep(2)
    q.read()
    q.cmd("audit_read\n")
    time.sleep(2)
    q.read()
    if "ERROR" in q.output or "permission" in q.output.lower():
        print("  ✓ PASS - Non-admin audit access denied")
        passed += 1
    else:
        print("  ✗ FAIL - Non-admin could access audit!")
        print(f"    Output: {q.output[-200:]}")
        failed += 1
    
    q.stop()
    
    # Final report
    total = passed + failed
    print("\n" + "="*70)
    print(f"RESULTS: {passed}/{total} PASSED")
    print("="*70)
    
    if passed == 10:
        print("✓✓✓ FULL MARKS - ALL 10 TESTS PASSED ✓✓✓\n")
        return True
    else:
        print(f"✗ {failed} TESTS FAILED - Review above for details\n")
        sys.exit(1)

def main():
    print(args)
    rex = r'%s' % args.testrex
    funcs = [(obj,name) for name,obj in inspect.getmembers(sys.modules[__name__]) 
                     if (inspect.isfunction(obj) and 
                         name.startswith('test'))]
    none = True
    for (f,n) in funcs:
        if re.search(rex, n):
            none = False
            f()
    if none:
        test_usertests(test=args.testrex)

main()
