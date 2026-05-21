
user/_sectest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_result>:
#define PASS_STR "[ PASS ]"
#define FAIL_STR "[ FAIL ]"

void
test_result(const char *name, int passed)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
       8:	862a                	mv	a2,a0
    tests_run++;
       a:	00002717          	auipc	a4,0x2
       e:	ffe70713          	addi	a4,a4,-2 # 2008 <tests_run>
      12:	431c                	lw	a5,0(a4)
      14:	2785                	addiw	a5,a5,1
      16:	c31c                	sw	a5,0(a4)
    if (passed) {
      18:	c595                	beqz	a1,44 <test_result+0x44>
        tests_passed++;
      1a:	00002717          	auipc	a4,0x2
      1e:	fea70713          	addi	a4,a4,-22 # 2004 <tests_passed>
      22:	431c                	lw	a5,0(a4)
      24:	2785                	addiw	a5,a5,1
      26:	c31c                	sw	a5,0(a4)
        printf("%s %s\n", PASS_STR, name);
      28:	00001597          	auipc	a1,0x1
      2c:	19858593          	addi	a1,a1,408 # 11c0 <malloc+0xf6>
      30:	00001517          	auipc	a0,0x1
      34:	1a050513          	addi	a0,a0,416 # 11d0 <malloc+0x106>
      38:	7db000ef          	jal	1012 <printf>
    } else {
        tests_failed++;
        printf("%s %s\n", FAIL_STR, name);
    }
}
      3c:	60a2                	ld	ra,8(sp)
      3e:	6402                	ld	s0,0(sp)
      40:	0141                	addi	sp,sp,16
      42:	8082                	ret
        tests_failed++;
      44:	00002717          	auipc	a4,0x2
      48:	fbc70713          	addi	a4,a4,-68 # 2000 <tests_failed>
      4c:	431c                	lw	a5,0(a4)
      4e:	2785                	addiw	a5,a5,1
      50:	c31c                	sw	a5,0(a4)
        printf("%s %s\n", FAIL_STR, name);
      52:	00001597          	auipc	a1,0x1
      56:	18658593          	addi	a1,a1,390 # 11d8 <malloc+0x10e>
      5a:	00001517          	auipc	a0,0x1
      5e:	17650513          	addi	a0,a0,374 # 11d0 <malloc+0x106>
      62:	7b1000ef          	jal	1012 <printf>
}
      66:	bfd9                	j	3c <test_result+0x3c>

0000000000000068 <test_admin_login>:

// =============================================================
// TEST 1: Valid admin login succeeds
// =============================================================
void test_admin_login(void) {
      68:	1141                	addi	sp,sp,-16
      6a:	e406                	sd	ra,8(sp)
      6c:	e022                	sd	s0,0(sp)
      6e:	0800                	addi	s0,sp,16
    int uid = login("admin", "admin123");
      70:	00001597          	auipc	a1,0x1
      74:	17858593          	addi	a1,a1,376 # 11e8 <malloc+0x11e>
      78:	00001517          	auipc	a0,0x1
      7c:	18050513          	addi	a0,a0,384 # 11f8 <malloc+0x12e>
      80:	3ad000ef          	jal	c2c <login>
    test_result("TC01: Admin login with correct credentials", uid == 0);
      84:	00153593          	seqz	a1,a0
      88:	00001517          	auipc	a0,0x1
      8c:	17850513          	addi	a0,a0,376 # 1200 <malloc+0x136>
      90:	f71ff0ef          	jal	0 <test_result>
}
      94:	60a2                	ld	ra,8(sp)
      96:	6402                	ld	s0,0(sp)
      98:	0141                	addi	sp,sp,16
      9a:	8082                	ret

000000000000009c <test_bad_password>:

// =============================================================
// TEST 2: Invalid password rejected
// =============================================================
void test_bad_password(void) {
      9c:	1141                	addi	sp,sp,-16
      9e:	e406                	sd	ra,8(sp)
      a0:	e022                	sd	s0,0(sp)
      a2:	0800                	addi	s0,sp,16
    int uid = login("admin", "wrongpassword");
      a4:	00001597          	auipc	a1,0x1
      a8:	18c58593          	addi	a1,a1,396 # 1230 <malloc+0x166>
      ac:	00001517          	auipc	a0,0x1
      b0:	14c50513          	addi	a0,a0,332 # 11f8 <malloc+0x12e>
      b4:	379000ef          	jal	c2c <login>
    test_result("TC02: Login with wrong password is denied", uid < 0);
      b8:	01f5559b          	srliw	a1,a0,0x1f
      bc:	00001517          	auipc	a0,0x1
      c0:	18450513          	addi	a0,a0,388 # 1240 <malloc+0x176>
      c4:	f3dff0ef          	jal	0 <test_result>
}
      c8:	60a2                	ld	ra,8(sp)
      ca:	6402                	ld	s0,0(sp)
      cc:	0141                	addi	sp,sp,16
      ce:	8082                	ret

00000000000000d0 <test_patient_login>:

// =============================================================
// TEST 3: Patient login succeeds with correct role
// =============================================================
void test_patient_login(void) {
      d0:	1141                	addi	sp,sp,-16
      d2:	e406                	sd	ra,8(sp)
      d4:	e022                	sd	s0,0(sp)
      d6:	0800                	addi	s0,sp,16
    int uid = login("patient", "patient123");
      d8:	00001597          	auipc	a1,0x1
      dc:	19858593          	addi	a1,a1,408 # 1270 <malloc+0x1a6>
      e0:	00001517          	auipc	a0,0x1
      e4:	1a050513          	addi	a0,a0,416 # 1280 <malloc+0x1b6>
      e8:	345000ef          	jal	c2c <login>
    test_result("TC03: Patient login returns UID=1", uid == 1);
      ec:	fff50593          	addi	a1,a0,-1
      f0:	0015b593          	seqz	a1,a1
      f4:	00001517          	auipc	a0,0x1
      f8:	19450513          	addi	a0,a0,404 # 1288 <malloc+0x1be>
      fc:	f05ff0ef          	jal	0 <test_result>
}
     100:	60a2                	ld	ra,8(sp)
     102:	6402                	ld	s0,0(sp)
     104:	0141                	addi	sp,sp,16
     106:	8082                	ret

0000000000000108 <test_patient_cannot_write_insulin>:
// =============================================================
// TEST 4: Patient cannot write to insulin.log
// Expected: write returns -1 (permission denied)
// Also tests: this denial should appear in audit log
// =============================================================
void test_patient_cannot_write_insulin(void) {
     108:	1101                	addi	sp,sp,-32
     10a:	ec06                	sd	ra,24(sp)
     10c:	e822                	sd	s0,16(sp)
     10e:	1000                	addi	s0,sp,32
    // Login as patient first
    login("patient", "patient123");
     110:	00001597          	auipc	a1,0x1
     114:	16058593          	addi	a1,a1,352 # 1270 <malloc+0x1a6>
     118:	00001517          	auipc	a0,0x1
     11c:	16850513          	addi	a0,a0,360 # 1280 <malloc+0x1b6>
     120:	30d000ef          	jal	c2c <login>

    int fd = open("/dosage/insulin.log", O_WRONLY);
     124:	4585                	li	a1,1
     126:	00001517          	auipc	a0,0x1
     12a:	18a50513          	addi	a0,a0,394 # 12b0 <malloc+0x1e6>
     12e:	29f000ef          	jal	bcc <open>
    if (fd >= 0) {
     132:	04054863          	bltz	a0,182 <test_patient_cannot_write_insulin+0x7a>
     136:	e426                	sd	s1,8(sp)
     138:	e04a                	sd	s2,0(sp)
     13a:	84aa                	mv	s1,a0
        int r = write(fd, "TAMPERED", 8);
     13c:	4621                	li	a2,8
     13e:	00001597          	auipc	a1,0x1
     142:	18a58593          	addi	a1,a1,394 # 12c8 <malloc+0x1fe>
     146:	267000ef          	jal	bac <write>
     14a:	892a                	mv	s2,a0
        close(fd);
     14c:	8526                	mv	a0,s1
     14e:	267000ef          	jal	bb4 <close>
        // Either open or write should have failed
        test_result("TC04: Patient DENIED write to insulin.log", r < 0);
     152:	01f9559b          	srliw	a1,s2,0x1f
     156:	00001517          	auipc	a0,0x1
     15a:	18250513          	addi	a0,a0,386 # 12d8 <malloc+0x20e>
     15e:	ea3ff0ef          	jal	0 <test_result>
     162:	64a2                	ld	s1,8(sp)
     164:	6902                	ld	s2,0(sp)
        // Good — open itself was denied
        test_result("TC04: Patient DENIED write to insulin.log (open denied)", 1);
    }

    // Re-login as admin for subsequent tests
    login("admin", "admin123");
     166:	00001597          	auipc	a1,0x1
     16a:	08258593          	addi	a1,a1,130 # 11e8 <malloc+0x11e>
     16e:	00001517          	auipc	a0,0x1
     172:	08a50513          	addi	a0,a0,138 # 11f8 <malloc+0x12e>
     176:	2b7000ef          	jal	c2c <login>
}
     17a:	60e2                	ld	ra,24(sp)
     17c:	6442                	ld	s0,16(sp)
     17e:	6105                	addi	sp,sp,32
     180:	8082                	ret
        test_result("TC04: Patient DENIED write to insulin.log (open denied)", 1);
     182:	4585                	li	a1,1
     184:	00001517          	auipc	a0,0x1
     188:	18450513          	addi	a0,a0,388 # 1308 <malloc+0x23e>
     18c:	e75ff0ef          	jal	0 <test_result>
     190:	bfd9                	j	166 <test_patient_cannot_write_insulin+0x5e>

0000000000000192 <test_patient_read_records>:

// =============================================================
// TEST 5: Patient can read own records
// =============================================================
void test_patient_read_records(void) {
     192:	1101                	addi	sp,sp,-32
     194:	ec06                	sd	ra,24(sp)
     196:	e822                	sd	s0,16(sp)
     198:	e426                	sd	s1,8(sp)
     19a:	1000                	addi	s0,sp,32
    login("patient", "patient123");
     19c:	00001597          	auipc	a1,0x1
     1a0:	0d458593          	addi	a1,a1,212 # 1270 <malloc+0x1a6>
     1a4:	00001517          	auipc	a0,0x1
     1a8:	0dc50513          	addi	a0,a0,220 # 1280 <malloc+0x1b6>
     1ac:	281000ef          	jal	c2c <login>

    int fd = open("/patient/records", O_RDONLY);
     1b0:	4581                	li	a1,0
     1b2:	00001517          	auipc	a0,0x1
     1b6:	18e50513          	addi	a0,a0,398 # 1340 <malloc+0x276>
     1ba:	213000ef          	jal	bcc <open>
    int passed = (fd >= 0);
     1be:	fff54793          	not	a5,a0
     1c2:	01f7d79b          	srliw	a5,a5,0x1f
     1c6:	84be                	mv	s1,a5
    if (fd >= 0) close(fd);
     1c8:	02055863          	bgez	a0,1f8 <test_patient_read_records+0x66>

    test_result("TC05: Patient ALLOWED read of /patient/records", passed);
     1cc:	85a6                	mv	a1,s1
     1ce:	00001517          	auipc	a0,0x1
     1d2:	18a50513          	addi	a0,a0,394 # 1358 <malloc+0x28e>
     1d6:	e2bff0ef          	jal	0 <test_result>
    login("admin", "admin123");
     1da:	00001597          	auipc	a1,0x1
     1de:	00e58593          	addi	a1,a1,14 # 11e8 <malloc+0x11e>
     1e2:	00001517          	auipc	a0,0x1
     1e6:	01650513          	addi	a0,a0,22 # 11f8 <malloc+0x12e>
     1ea:	243000ef          	jal	c2c <login>
}
     1ee:	60e2                	ld	ra,24(sp)
     1f0:	6442                	ld	s0,16(sp)
     1f2:	64a2                	ld	s1,8(sp)
     1f4:	6105                	addi	sp,sp,32
     1f6:	8082                	ret
    if (fd >= 0) close(fd);
     1f8:	1bd000ef          	jal	bb4 <close>
     1fc:	bfc1                	j	1cc <test_patient_read_records+0x3a>

00000000000001fe <test_doctor_write_insulin>:

// =============================================================
// TEST 6: Doctor can write insulin.log
// =============================================================
void test_doctor_write_insulin(void) {
     1fe:	1101                	addi	sp,sp,-32
     200:	ec06                	sd	ra,24(sp)
     202:	e822                	sd	s0,16(sp)
     204:	e04a                	sd	s2,0(sp)
     206:	1000                	addi	s0,sp,32
    login("doctor", "doctor123");
     208:	00001597          	auipc	a1,0x1
     20c:	18058593          	addi	a1,a1,384 # 1388 <malloc+0x2be>
     210:	00001517          	auipc	a0,0x1
     214:	18850513          	addi	a0,a0,392 # 1398 <malloc+0x2ce>
     218:	215000ef          	jal	c2c <login>

    int fd = open("/dosage/insulin.log", O_WRONLY | O_APPEND);
     21c:	6585                	lui	a1,0x1
     21e:	80158593          	addi	a1,a1,-2047 # 801 <generate_compliance_report+0x349>
     222:	00001517          	auipc	a0,0x1
     226:	08e50513          	addi	a0,a0,142 # 12b0 <malloc+0x1e6>
     22a:	1a3000ef          	jal	bcc <open>
    int passed = 0;
     22e:	4901                	li	s2,0
    if (fd >= 0) {
     230:	02055863          	bgez	a0,260 <test_doctor_write_insulin+0x62>
        int r = write(fd, "dose:5units\n", 12);
        passed = (r == 12);
        close(fd);
    }

    test_result("TC06: Doctor ALLOWED write to insulin.log", passed);
     234:	85ca                	mv	a1,s2
     236:	00001517          	auipc	a0,0x1
     23a:	17a50513          	addi	a0,a0,378 # 13b0 <malloc+0x2e6>
     23e:	dc3ff0ef          	jal	0 <test_result>
    login("admin", "admin123");
     242:	00001597          	auipc	a1,0x1
     246:	fa658593          	addi	a1,a1,-90 # 11e8 <malloc+0x11e>
     24a:	00001517          	auipc	a0,0x1
     24e:	fae50513          	addi	a0,a0,-82 # 11f8 <malloc+0x12e>
     252:	1db000ef          	jal	c2c <login>
}
     256:	60e2                	ld	ra,24(sp)
     258:	6442                	ld	s0,16(sp)
     25a:	6902                	ld	s2,0(sp)
     25c:	6105                	addi	sp,sp,32
     25e:	8082                	ret
     260:	e426                	sd	s1,8(sp)
     262:	84aa                	mv	s1,a0
        int r = write(fd, "dose:5units\n", 12);
     264:	4631                	li	a2,12
     266:	00001597          	auipc	a1,0x1
     26a:	13a58593          	addi	a1,a1,314 # 13a0 <malloc+0x2d6>
     26e:	13f000ef          	jal	bac <write>
        passed = (r == 12);
     272:	1551                	addi	a0,a0,-12
     274:	00153793          	seqz	a5,a0
     278:	893e                	mv	s2,a5
        close(fd);
     27a:	8526                	mv	a0,s1
     27c:	139000ef          	jal	bb4 <close>
     280:	64a2                	ld	s1,8(sp)
     282:	bf4d                	j	234 <test_doctor_write_insulin+0x36>

0000000000000284 <test_patient_cannot_read_config>:

// =============================================================
// TEST 7: Patient cannot access /device/config
// =============================================================
void test_patient_cannot_read_config(void) {
     284:	1101                	addi	sp,sp,-32
     286:	ec06                	sd	ra,24(sp)
     288:	e822                	sd	s0,16(sp)
     28a:	e426                	sd	s1,8(sp)
     28c:	1000                	addi	s0,sp,32
    login("patient", "patient123");
     28e:	00001597          	auipc	a1,0x1
     292:	fe258593          	addi	a1,a1,-30 # 1270 <malloc+0x1a6>
     296:	00001517          	auipc	a0,0x1
     29a:	fea50513          	addi	a0,a0,-22 # 1280 <malloc+0x1b6>
     29e:	18f000ef          	jal	c2c <login>

    int fd = open("/device/config", O_RDONLY);
     2a2:	4581                	li	a1,0
     2a4:	00001517          	auipc	a0,0x1
     2a8:	13c50513          	addi	a0,a0,316 # 13e0 <malloc+0x316>
     2ac:	121000ef          	jal	bcc <open>
    int denied = (fd < 0);
     2b0:	01f5579b          	srliw	a5,a0,0x1f
     2b4:	84be                	mv	s1,a5
    if (fd >= 0) close(fd);
     2b6:	02055863          	bgez	a0,2e6 <test_patient_cannot_read_config+0x62>

    test_result("TC07: Patient DENIED read of /device/config", denied);
     2ba:	85a6                	mv	a1,s1
     2bc:	00001517          	auipc	a0,0x1
     2c0:	13450513          	addi	a0,a0,308 # 13f0 <malloc+0x326>
     2c4:	d3dff0ef          	jal	0 <test_result>
    login("admin", "admin123");
     2c8:	00001597          	auipc	a1,0x1
     2cc:	f2058593          	addi	a1,a1,-224 # 11e8 <malloc+0x11e>
     2d0:	00001517          	auipc	a0,0x1
     2d4:	f2850513          	addi	a0,a0,-216 # 11f8 <malloc+0x12e>
     2d8:	155000ef          	jal	c2c <login>
}
     2dc:	60e2                	ld	ra,24(sp)
     2de:	6442                	ld	s0,16(sp)
     2e0:	64a2                	ld	s1,8(sp)
     2e2:	6105                	addi	sp,sp,32
     2e4:	8082                	ret
    if (fd >= 0) close(fd);
     2e6:	0cf000ef          	jal	bb4 <close>
     2ea:	bfc1                	j	2ba <test_patient_cannot_read_config+0x36>

00000000000002ec <test_doctor_cannot_read_config>:

// =============================================================
// TEST 8: Doctor cannot access /device/config
// =============================================================
void test_doctor_cannot_read_config(void) {
     2ec:	1101                	addi	sp,sp,-32
     2ee:	ec06                	sd	ra,24(sp)
     2f0:	e822                	sd	s0,16(sp)
     2f2:	e426                	sd	s1,8(sp)
     2f4:	1000                	addi	s0,sp,32
    login("doctor", "doctor123");
     2f6:	00001597          	auipc	a1,0x1
     2fa:	09258593          	addi	a1,a1,146 # 1388 <malloc+0x2be>
     2fe:	00001517          	auipc	a0,0x1
     302:	09a50513          	addi	a0,a0,154 # 1398 <malloc+0x2ce>
     306:	127000ef          	jal	c2c <login>

    int fd = open("/device/config", O_RDONLY);
     30a:	4581                	li	a1,0
     30c:	00001517          	auipc	a0,0x1
     310:	0d450513          	addi	a0,a0,212 # 13e0 <malloc+0x316>
     314:	0b9000ef          	jal	bcc <open>
    int denied = (fd < 0);
     318:	01f5579b          	srliw	a5,a0,0x1f
     31c:	84be                	mv	s1,a5
    if (fd >= 0) close(fd);
     31e:	02055863          	bgez	a0,34e <test_doctor_cannot_read_config+0x62>

    test_result("TC08: Doctor DENIED read of /device/config", denied);
     322:	85a6                	mv	a1,s1
     324:	00001517          	auipc	a0,0x1
     328:	0fc50513          	addi	a0,a0,252 # 1420 <malloc+0x356>
     32c:	cd5ff0ef          	jal	0 <test_result>
    login("admin", "admin123");
     330:	00001597          	auipc	a1,0x1
     334:	eb858593          	addi	a1,a1,-328 # 11e8 <malloc+0x11e>
     338:	00001517          	auipc	a0,0x1
     33c:	ec050513          	addi	a0,a0,-320 # 11f8 <malloc+0x12e>
     340:	0ed000ef          	jal	c2c <login>
}
     344:	60e2                	ld	ra,24(sp)
     346:	6442                	ld	s0,16(sp)
     348:	64a2                	ld	s1,8(sp)
     34a:	6105                	addi	sp,sp,32
     34c:	8082                	ret
    if (fd >= 0) close(fd);
     34e:	067000ef          	jal	bb4 <close>
     352:	bfc1                	j	322 <test_doctor_cannot_read_config+0x36>

0000000000000354 <test_patient_cannot_read_audit>:

// =============================================================
// TEST 9: Non-admin cannot read audit log via audit_read
// =============================================================
void test_patient_cannot_read_audit(void) {
     354:	df010113          	addi	sp,sp,-528
     358:	20113423          	sd	ra,520(sp)
     35c:	20813023          	sd	s0,512(sp)
     360:	0c00                	addi	s0,sp,528
    login("patient", "patient123");
     362:	00001597          	auipc	a1,0x1
     366:	f0e58593          	addi	a1,a1,-242 # 1270 <malloc+0x1a6>
     36a:	00001517          	auipc	a0,0x1
     36e:	f1650513          	addi	a0,a0,-234 # 1280 <malloc+0x1b6>
     372:	0bb000ef          	jal	c2c <login>

    char buf[512];
    int r = audit_read(buf, 512);
     376:	20000593          	li	a1,512
     37a:	df040513          	addi	a0,s0,-528
     37e:	0e7000ef          	jal	c64 <audit_read>
    test_result("TC09: Patient audit_read returns EPERM", r < 0);
     382:	01f5559b          	srliw	a1,a0,0x1f
     386:	00001517          	auipc	a0,0x1
     38a:	0ca50513          	addi	a0,a0,202 # 1450 <malloc+0x386>
     38e:	c73ff0ef          	jal	0 <test_result>

    login("admin", "admin123");
     392:	00001597          	auipc	a1,0x1
     396:	e5658593          	addi	a1,a1,-426 # 11e8 <malloc+0x11e>
     39a:	00001517          	auipc	a0,0x1
     39e:	e5e50513          	addi	a0,a0,-418 # 11f8 <malloc+0x12e>
     3a2:	08b000ef          	jal	c2c <login>
}
     3a6:	20813083          	ld	ra,520(sp)
     3aa:	20013403          	ld	s0,512(sp)
     3ae:	21010113          	addi	sp,sp,528
     3b2:	8082                	ret

00000000000003b4 <test_admin_can_read_audit>:

// =============================================================
// TEST 10: Admin can read audit log
// =============================================================
void test_admin_can_read_audit(void) {
     3b4:	1101                	addi	sp,sp,-32
     3b6:	ec06                	sd	ra,24(sp)
     3b8:	e822                	sd	s0,16(sp)
     3ba:	1000                	addi	s0,sp,32
     3bc:	81010113          	addi	sp,sp,-2032
    login("admin", "admin123");
     3c0:	00001597          	auipc	a1,0x1
     3c4:	e2858593          	addi	a1,a1,-472 # 11e8 <malloc+0x11e>
     3c8:	00001517          	auipc	a0,0x1
     3cc:	e3050513          	addi	a0,a0,-464 # 11f8 <malloc+0x12e>
     3d0:	05d000ef          	jal	c2c <login>

    char buf[2048];
    int r = audit_read(buf, 2048);
     3d4:	6585                	lui	a1,0x1
     3d6:	80058593          	addi	a1,a1,-2048 # 800 <generate_compliance_report+0x348>
     3da:	80040513          	addi	a0,s0,-2048
     3de:	1541                	addi	a0,a0,-16
     3e0:	085000ef          	jal	c64 <audit_read>
    test_result("TC10: Admin audit_read succeeds (bytes read > 0)", r > 0);
     3e4:	00a025b3          	sgtz	a1,a0
     3e8:	00001517          	auipc	a0,0x1
     3ec:	09050513          	addi	a0,a0,144 # 1478 <malloc+0x3ae>
     3f0:	c11ff0ef          	jal	0 <test_result>
}
     3f4:	7f010113          	addi	sp,sp,2032
     3f8:	60e2                	ld	ra,24(sp)
     3fa:	6442                	ld	s0,16(sp)
     3fc:	6105                	addi	sp,sp,32
     3fe:	8082                	ret

0000000000000400 <test_patient_cannot_useradd>:

// =============================================================
// TEST 11: Non-admin cannot useradd
// =============================================================
void test_patient_cannot_useradd(void) {
     400:	1141                	addi	sp,sp,-16
     402:	e406                	sd	ra,8(sp)
     404:	e022                	sd	s0,0(sp)
     406:	0800                	addi	s0,sp,16
    login("patient", "patient123");
     408:	00001597          	auipc	a1,0x1
     40c:	e6858593          	addi	a1,a1,-408 # 1270 <malloc+0x1a6>
     410:	00001517          	auipc	a0,0x1
     414:	e7050513          	addi	a0,a0,-400 # 1280 <malloc+0x1b6>
     418:	015000ef          	jal	c2c <login>

    int r = useradd("hacker", "hacked", 0, 0);
     41c:	4681                	li	a3,0
     41e:	4601                	li	a2,0
     420:	00001597          	auipc	a1,0x1
     424:	09058593          	addi	a1,a1,144 # 14b0 <malloc+0x3e6>
     428:	00001517          	auipc	a0,0x1
     42c:	09050513          	addi	a0,a0,144 # 14b8 <malloc+0x3ee>
     430:	005000ef          	jal	c34 <useradd>
    test_result("TC11: Patient DENIED useradd (would escalate to admin)", r < 0);
     434:	01f5559b          	srliw	a1,a0,0x1f
     438:	00001517          	auipc	a0,0x1
     43c:	08850513          	addi	a0,a0,136 # 14c0 <malloc+0x3f6>
     440:	bc1ff0ef          	jal	0 <test_result>

    login("admin", "admin123");
     444:	00001597          	auipc	a1,0x1
     448:	da458593          	addi	a1,a1,-604 # 11e8 <malloc+0x11e>
     44c:	00001517          	auipc	a0,0x1
     450:	dac50513          	addi	a0,a0,-596 # 11f8 <malloc+0x12e>
     454:	7d8000ef          	jal	c2c <login>
}
     458:	60a2                	ld	ra,8(sp)
     45a:	6402                	ld	s0,0(sp)
     45c:	0141                	addi	sp,sp,16
     45e:	8082                	ret

0000000000000460 <test_nonowner_chmod_denied>:

// =============================================================
// TEST 12: chmod by non-owner is denied
// =============================================================
void test_nonowner_chmod_denied(void) {
     460:	1141                	addi	sp,sp,-16
     462:	e406                	sd	ra,8(sp)
     464:	e022                	sd	s0,0(sp)
     466:	0800                	addi	s0,sp,16
    login("patient", "patient123");
     468:	00001597          	auipc	a1,0x1
     46c:	e0858593          	addi	a1,a1,-504 # 1270 <malloc+0x1a6>
     470:	00001517          	auipc	a0,0x1
     474:	e1050513          	addi	a0,a0,-496 # 1280 <malloc+0x1b6>
     478:	7b4000ef          	jal	c2c <login>

    // Patient trying to chmod doctor's file
    int r = chmod("/dosage/insulin.log", 0777);
     47c:	1ff00593          	li	a1,511
     480:	00001517          	auipc	a0,0x1
     484:	e3050513          	addi	a0,a0,-464 # 12b0 <malloc+0x1e6>
     488:	7cc000ef          	jal	c54 <chmod>
    test_result("TC12: Patient DENIED chmod on doctor-owned file", r < 0);
     48c:	01f5559b          	srliw	a1,a0,0x1f
     490:	00001517          	auipc	a0,0x1
     494:	06850513          	addi	a0,a0,104 # 14f8 <malloc+0x42e>
     498:	b69ff0ef          	jal	0 <test_result>

    login("admin", "admin123");
     49c:	00001597          	auipc	a1,0x1
     4a0:	d4c58593          	addi	a1,a1,-692 # 11e8 <malloc+0x11e>
     4a4:	00001517          	auipc	a0,0x1
     4a8:	d5450513          	addi	a0,a0,-684 # 11f8 <malloc+0x12e>
     4ac:	780000ef          	jal	c2c <login>
}
     4b0:	60a2                	ld	ra,8(sp)
     4b2:	6402                	ld	s0,0(sp)
     4b4:	0141                	addi	sp,sp,16
     4b6:	8082                	ret

00000000000004b8 <generate_compliance_report>:
// COMPLIANCE REPORT GENERATOR
// Reads audit log and counts security events by category
// =============================================================
void
generate_compliance_report(void)
{
     4b8:	7139                	addi	sp,sp,-64
     4ba:	fc06                	sd	ra,56(sp)
     4bc:	f822                	sd	s0,48(sp)
     4be:	f426                	sd	s1,40(sp)
     4c0:	f04a                	sd	s2,32(sp)
     4c2:	ec4e                	sd	s3,24(sp)
     4c4:	e852                	sd	s4,16(sp)
     4c6:	e456                	sd	s5,8(sp)
     4c8:	0080                	addi	s0,sp,64
     4ca:	80010113          	addi	sp,sp,-2048
     4ce:	80010113          	addi	sp,sp,-2048
    printf("\n");
     4d2:	00001517          	auipc	a0,0x1
     4d6:	24650513          	addi	a0,a0,582 # 1718 <malloc+0x64e>
     4da:	339000ef          	jal	1012 <printf>
    printf("════════════════════════════════════════════════\n");
     4de:	00001517          	auipc	a0,0x1
     4e2:	04a50513          	addi	a0,a0,74 # 1528 <malloc+0x45e>
     4e6:	32d000ef          	jal	1012 <printf>
    printf("   MEDICAL DEVICE SECURITY COMPLIANCE REPORT   \n");
     4ea:	00001517          	auipc	a0,0x1
     4ee:	0d650513          	addi	a0,a0,214 # 15c0 <malloc+0x4f6>
     4f2:	321000ef          	jal	1012 <printf>
    printf("════════════════════════════════════════════════\n\n");
     4f6:	00001517          	auipc	a0,0x1
     4fa:	10250513          	addi	a0,a0,258 # 15f8 <malloc+0x52e>
     4fe:	315000ef          	jal	1012 <printf>

    char buf[4096];
    int n = audit_read(buf, 4096);
     502:	6585                	lui	a1,0x1
     504:	80040513          	addi	a0,s0,-2048
     508:	fc050513          	addi	a0,a0,-64
     50c:	80050513          	addi	a0,a0,-2048
     510:	754000ef          	jal	c64 <audit_read>

    if (n < 0) {
     514:	06054663          	bltz	a0,580 <generate_compliance_report+0xc8>
    int login_fail   = 0;
    int login_ok     = 0;
    int perm_denied  = 0;

    struct audit_entry *entries = (struct audit_entry*)buf;
    int num_entries = n / sizeof(struct audit_entry);
     518:	00083737          	lui	a4,0x83
     51c:	d8370713          	addi	a4,a4,-637 # 82d83 <base+0x80d63>
     520:	0732                	slli	a4,a4,0xc
     522:	d8370713          	addi	a4,a4,-637
     526:	2d82e7b7          	lui	a5,0x2d82e
     52a:	82d78793          	addi	a5,a5,-2003 # 2d82d82d <base+0x2d82b80d>
     52e:	1782                	slli	a5,a5,0x20
     530:	97ba                	add	a5,a5,a4
     532:	02f53533          	mulhu	a0,a0,a5
     536:	8115                	srli	a0,a0,0x5

    for (int i = 0; i < num_entries; i++) {
     538:	0005079b          	sext.w	a5,a0
     53c:	1af05d63          	blez	a5,6f6 <generate_compliance_report+0x23e>
     540:	80040793          	addi	a5,s0,-2048
     544:	fc078793          	addi	a5,a5,-64
     548:	82d78613          	addi	a2,a5,-2003
     54c:	fff5081b          	addiw	a6,a0,-1
     550:	1802                	slli	a6,a6,0x20
     552:	02085813          	srli	a6,a6,0x20
     556:	0b400713          	li	a4,180
     55a:	02e80833          	mul	a6,a6,a4
     55e:	8e178793          	addi	a5,a5,-1823
     562:	983e                	add	a6,a6,a5
    int login_ok     = 0;
     564:	4a81                	li	s5,0
    int login_fail   = 0;
     566:	4981                	li	s3,0
    int denied_count = 0;
     568:	4481                	li	s1,0
    int total        = 0;
     56a:	4901                	li	s2,0
        // Simple string matching on message field
        char *m = e->message;
        // Check for DENIED
        int is_denied = 0;
        for (int j = 0; m[j] && m[j+5]; j++) {
            if (m[j]=='D' && m[j+1]=='E' && m[j+2]=='N' &&
     56c:	04400593          	li	a1,68
     570:	04500893          	li	a7,69
     574:	04e00e13          	li	t3,78
            }
        }
        if (is_denied) denied_count++;

        // Check for login events
        if (e->syscall_num == SYS_login) {
     578:	4ed9                	li	t4,22
            if (m[j]=='D' && m[j+1]=='E' && m[j+2]=='N' &&
     57a:	04900f13          	li	t5,73
     57e:	a095                	j	5e2 <generate_compliance_report+0x12a>
        printf("ERROR: Could not read audit log (not admin?)\n");
     580:	00001517          	auipc	a0,0x1
     584:	11050513          	addi	a0,a0,272 # 1690 <malloc+0x5c6>
     588:	28b000ef          	jal	1012 <printf>
        return;
     58c:	ac85                	j	7fc <generate_compliance_report+0x344>
        for (int j = 0; m[j] && m[j+5]; j++) {
     58e:	0785                	addi	a5,a5,1
     590:	fff7c703          	lbu	a4,-1(a5)
     594:	26070f63          	beqz	a4,812 <generate_compliance_report+0x35a>
     598:	0047c683          	lbu	a3,4(a5)
     59c:	ca8d                	beqz	a3,5ce <generate_compliance_report+0x116>
            if (m[j]=='D' && m[j+1]=='E' && m[j+2]=='N' &&
     59e:	feb718e3          	bne	a4,a1,58e <generate_compliance_report+0xd6>
     5a2:	0007c703          	lbu	a4,0(a5)
     5a6:	ff1714e3          	bne	a4,a7,58e <generate_compliance_report+0xd6>
     5aa:	0017c703          	lbu	a4,1(a5)
     5ae:	ffc710e3          	bne	a4,t3,58e <generate_compliance_report+0xd6>
     5b2:	0027c703          	lbu	a4,2(a5)
     5b6:	fde71ce3          	bne	a4,t5,58e <generate_compliance_report+0xd6>
                m[j+3]=='I' && m[j+4]=='E' && m[j+5]=='D') {
     5ba:	0037c703          	lbu	a4,3(a5)
     5be:	fbb70713          	addi	a4,a4,-69
     5c2:	f771                	bnez	a4,58e <generate_compliance_report+0xd6>
     5c4:	fbc68693          	addi	a3,a3,-68
     5c8:	f2f9                	bnez	a3,58e <generate_compliance_report+0xd6>
                is_denied = 1;
     5ca:	4785                	li	a5,1
     5cc:	a011                	j	5d0 <generate_compliance_report+0x118>
        int is_denied = 0;
     5ce:	4781                	li	a5,0
        if (is_denied) denied_count++;
     5d0:	9cbd                	addw	s1,s1,a5
        if (e->syscall_num == SYS_login) {
     5d2:	fdb32783          	lw	a5,-37(t1)
     5d6:	05d78c63          	beq	a5,t4,62e <generate_compliance_report+0x176>
    for (int i = 0; i < num_entries; i++) {
     5da:	0b460613          	addi	a2,a2,180
     5de:	07060063          	beq	a2,a6,63e <generate_compliance_report+0x186>
        if (!e->valid) continue;
     5e2:	8332                	mv	t1,a2
     5e4:	08362783          	lw	a5,131(a2)
     5e8:	dbed                	beqz	a5,5da <generate_compliance_report+0x122>
        total++;
     5ea:	2905                	addiw	s2,s2,1
        for (int j = 0; m[j] && m[j+5]; j++) {
     5ec:	fff64503          	lbu	a0,-1(a2)
     5f0:	87b2                	mv	a5,a2
     5f2:	872a                	mv	a4,a0
     5f4:	f155                	bnez	a0,598 <generate_compliance_report+0xe0>
        if (e->syscall_num == SYS_login) {
     5f6:	fdb62703          	lw	a4,-37(a2)
     5fa:	47d9                	li	a5,22
     5fc:	fcf71fe3          	bne	a4,a5,5da <generate_compliance_report+0x122>
                if (m[j]=='S' && m[j+1]=='U' && m[j+2]=='C') {
                    is_success = 1; break;
                }
            }
            if (is_success) login_ok++;
            else login_fail++;
     600:	2985                	addiw	s3,s3,1
     602:	bfe1                	j	5da <generate_compliance_report+0x122>
            for (int j = 0; m[j] && m[j+6]; j++) {
     604:	0785                	addi	a5,a5,1
     606:	fff7c503          	lbu	a0,-1(a5)
     60a:	d97d                	beqz	a0,600 <generate_compliance_report+0x148>
     60c:	0057c703          	lbu	a4,5(a5)
     610:	db65                	beqz	a4,600 <generate_compliance_report+0x148>
                if (m[j]=='S' && m[j+1]=='U' && m[j+2]=='C') {
     612:	fed519e3          	bne	a0,a3,604 <generate_compliance_report+0x14c>
     616:	0007c703          	lbu	a4,0(a5)
     61a:	fe6715e3          	bne	a4,t1,604 <generate_compliance_report+0x14c>
     61e:	0017c703          	lbu	a4,1(a5)
     622:	fff711e3          	bne	a4,t6,604 <generate_compliance_report+0x14c>
            if (is_success) login_ok++;
     626:	001a879b          	addiw	a5,s5,1
     62a:	8abe                	mv	s5,a5
     62c:	b77d                	j	5da <generate_compliance_report+0x122>
        if (e->syscall_num == SYS_login) {
     62e:	87b2                	mv	a5,a2
                if (m[j]=='S' && m[j+1]=='U' && m[j+2]=='C') {
     630:	05300693          	li	a3,83
     634:	05500313          	li	t1,85
     638:	04300f93          	li	t6,67
     63c:	bfc1                	j	60c <generate_compliance_report+0x154>
        }
    }

    perm_denied = denied_count - login_fail;
     63e:	413487bb          	subw	a5,s1,s3
     642:	8a3e                	mv	s4,a5

    printf("  Period: Boot to current tick\n");
     644:	00001517          	auipc	a0,0x1
     648:	07c50513          	addi	a0,a0,124 # 16c0 <malloc+0x5f6>
     64c:	1c7000ef          	jal	1012 <printf>
    printf("  Device: xv6 Medical Wearable (Insulin Pump Simulator)\n\n");
     650:	00001517          	auipc	a0,0x1
     654:	09050513          	addi	a0,a0,144 # 16e0 <malloc+0x616>
     658:	1bb000ef          	jal	1012 <printf>
    printf("  ┌──────────────────────────────────┬───────┐\n");
     65c:	00001517          	auipc	a0,0x1
     660:	0c450513          	addi	a0,a0,196 # 1720 <malloc+0x656>
     664:	1af000ef          	jal	1012 <printf>
    printf("  │ Metric                           │ Count │\n");
     668:	00001517          	auipc	a0,0x1
     66c:	14050513          	addi	a0,a0,320 # 17a8 <malloc+0x6de>
     670:	1a3000ef          	jal	1012 <printf>
    printf("  ├──────────────────────────────────┼───────┤\n");
     674:	00001517          	auipc	a0,0x1
     678:	16c50513          	addi	a0,a0,364 # 17e0 <malloc+0x716>
     67c:	197000ef          	jal	1012 <printf>
    printf("  │ Total Audit Events               │ %5d │\n", total);
     680:	85ca                	mv	a1,s2
     682:	00001517          	auipc	a0,0x1
     686:	1e650513          	addi	a0,a0,486 # 1868 <malloc+0x79e>
     68a:	189000ef          	jal	1012 <printf>
    printf("  │ Successful Logins                │ %5d │\n", login_ok);
     68e:	85d6                	mv	a1,s5
     690:	00001517          	auipc	a0,0x1
     694:	21050513          	addi	a0,a0,528 # 18a0 <malloc+0x7d6>
     698:	17b000ef          	jal	1012 <printf>
    printf("  │ Failed Login Attempts            │ %5d │\n", login_fail);
     69c:	85ce                	mv	a1,s3
     69e:	00001517          	auipc	a0,0x1
     6a2:	23a50513          	addi	a0,a0,570 # 18d8 <malloc+0x80e>
     6a6:	16d000ef          	jal	1012 <printf>
    printf("  │ Permission Violations            │ %5d │\n", perm_denied);
     6aa:	85d2                	mv	a1,s4
     6ac:	00001517          	auipc	a0,0x1
     6b0:	26450513          	addi	a0,a0,612 # 1910 <malloc+0x846>
     6b4:	15f000ef          	jal	1012 <printf>
    printf("  │ Total Denied Operations          │ %5d │\n", denied_count);
     6b8:	85a6                	mv	a1,s1
     6ba:	00001517          	auipc	a0,0x1
     6be:	28e50513          	addi	a0,a0,654 # 1948 <malloc+0x87e>
     6c2:	151000ef          	jal	1012 <printf>
    printf("  └──────────────────────────────────┴───────┘\n\n");
     6c6:	00001517          	auipc	a0,0x1
     6ca:	2ba50513          	addi	a0,a0,698 # 1980 <malloc+0x8b6>
     6ce:	145000ef          	jal	1012 <printf>

    printf("  Compliance Status: ");
     6d2:	00001517          	auipc	a0,0x1
     6d6:	33e50513          	addi	a0,a0,830 # 1a10 <malloc+0x946>
     6da:	139000ef          	jal	1012 <printf>
    if (login_fail == 0 && denied_count == 0) {
     6de:	0134e9b3          	or	s3,s1,s3
     6e2:	0a098763          	beqz	s3,790 <generate_compliance_report+0x2d8>
        printf("CLEAN — No violations detected\n");
    } else {
        printf("REVIEW REQUIRED — %d event(s) need attention\n", denied_count);
     6e6:	85a6                	mv	a1,s1
     6e8:	00001517          	auipc	a0,0x1
     6ec:	36850513          	addi	a0,a0,872 # 1a50 <malloc+0x986>
     6f0:	123000ef          	jal	1012 <printf>
     6f4:	a065                	j	79c <generate_compliance_report+0x2e4>
    printf("  Period: Boot to current tick\n");
     6f6:	00001517          	auipc	a0,0x1
     6fa:	fca50513          	addi	a0,a0,-54 # 16c0 <malloc+0x5f6>
     6fe:	115000ef          	jal	1012 <printf>
    printf("  Device: xv6 Medical Wearable (Insulin Pump Simulator)\n\n");
     702:	00001517          	auipc	a0,0x1
     706:	fde50513          	addi	a0,a0,-34 # 16e0 <malloc+0x616>
     70a:	109000ef          	jal	1012 <printf>
    printf("  ┌──────────────────────────────────┬───────┐\n");
     70e:	00001517          	auipc	a0,0x1
     712:	01250513          	addi	a0,a0,18 # 1720 <malloc+0x656>
     716:	0fd000ef          	jal	1012 <printf>
    printf("  │ Metric                           │ Count │\n");
     71a:	00001517          	auipc	a0,0x1
     71e:	08e50513          	addi	a0,a0,142 # 17a8 <malloc+0x6de>
     722:	0f1000ef          	jal	1012 <printf>
    printf("  ├──────────────────────────────────┼───────┤\n");
     726:	00001517          	auipc	a0,0x1
     72a:	0ba50513          	addi	a0,a0,186 # 17e0 <malloc+0x716>
     72e:	0e5000ef          	jal	1012 <printf>
    printf("  │ Total Audit Events               │ %5d │\n", total);
     732:	4581                	li	a1,0
     734:	00001517          	auipc	a0,0x1
     738:	13450513          	addi	a0,a0,308 # 1868 <malloc+0x79e>
     73c:	0d7000ef          	jal	1012 <printf>
    printf("  │ Successful Logins                │ %5d │\n", login_ok);
     740:	4581                	li	a1,0
     742:	00001517          	auipc	a0,0x1
     746:	15e50513          	addi	a0,a0,350 # 18a0 <malloc+0x7d6>
     74a:	0c9000ef          	jal	1012 <printf>
    printf("  │ Failed Login Attempts            │ %5d │\n", login_fail);
     74e:	4581                	li	a1,0
     750:	00001517          	auipc	a0,0x1
     754:	18850513          	addi	a0,a0,392 # 18d8 <malloc+0x80e>
     758:	0bb000ef          	jal	1012 <printf>
    printf("  │ Permission Violations            │ %5d │\n", perm_denied);
     75c:	4581                	li	a1,0
     75e:	00001517          	auipc	a0,0x1
     762:	1b250513          	addi	a0,a0,434 # 1910 <malloc+0x846>
     766:	0ad000ef          	jal	1012 <printf>
    printf("  │ Total Denied Operations          │ %5d │\n", denied_count);
     76a:	4581                	li	a1,0
     76c:	00001517          	auipc	a0,0x1
     770:	1dc50513          	addi	a0,a0,476 # 1948 <malloc+0x87e>
     774:	09f000ef          	jal	1012 <printf>
    printf("  └──────────────────────────────────┴───────┘\n\n");
     778:	00001517          	auipc	a0,0x1
     77c:	20850513          	addi	a0,a0,520 # 1980 <malloc+0x8b6>
     780:	093000ef          	jal	1012 <printf>
    printf("  Compliance Status: ");
     784:	00001517          	auipc	a0,0x1
     788:	28c50513          	addi	a0,a0,652 # 1a10 <malloc+0x946>
     78c:	087000ef          	jal	1012 <printf>
        printf("CLEAN — No violations detected\n");
     790:	00001517          	auipc	a0,0x1
     794:	29850513          	addi	a0,a0,664 # 1a28 <malloc+0x95e>
     798:	07b000ef          	jal	1012 <printf>
    }

    printf("\n  Security Controls Active:\n");
     79c:	00001517          	auipc	a0,0x1
     7a0:	2e450513          	addi	a0,a0,740 # 1a80 <malloc+0x9b6>
     7a4:	06f000ef          	jal	1012 <printf>
    printf("    [✓] Role-Based Access Control (RBAC)\n");
     7a8:	00001517          	auipc	a0,0x1
     7ac:	2f850513          	addi	a0,a0,760 # 1aa0 <malloc+0x9d6>
     7b0:	063000ef          	jal	1012 <printf>
    printf("    [✓] UNIX-style File Permissions (ACL on disk)\n");
     7b4:	00001517          	auipc	a0,0x1
     7b8:	31c50513          	addi	a0,a0,796 # 1ad0 <malloc+0xa06>
     7bc:	057000ef          	jal	1012 <printf>
    printf("    [✓] Capability List (in-memory auth table)\n");
     7c0:	00001517          	auipc	a0,0x1
     7c4:	34850513          	addi	a0,a0,840 # 1b08 <malloc+0xa3e>
     7c8:	04b000ef          	jal	1012 <printf>
    printf("    [✓] Syscall Audit Ring Buffer\n");
     7cc:	00001517          	auipc	a0,0x1
     7d0:	37450513          	addi	a0,a0,884 # 1b40 <malloc+0xa76>
     7d4:	03f000ef          	jal	1012 <printf>
    printf("    [✓] Stack Canary (proc->stack_canary)\n");
     7d8:	00001517          	auipc	a0,0x1
     7dc:	39050513          	addi	a0,a0,912 # 1b68 <malloc+0xa9e>
     7e0:	033000ef          	jal	1012 <printf>
    printf("    [✓] Principle of Least Privilege enforced\n");
     7e4:	00001517          	auipc	a0,0x1
     7e8:	3b450513          	addi	a0,a0,948 # 1b98 <malloc+0xace>
     7ec:	027000ef          	jal	1012 <printf>
    printf("\n════════════════════════════════════════════════\n");
     7f0:	00001517          	auipc	a0,0x1
     7f4:	3e050513          	addi	a0,a0,992 # 1bd0 <malloc+0xb06>
     7f8:	01b000ef          	jal	1012 <printf>
}
     7fc:	6285                	lui	t0,0x1
     7fe:	9116                	add	sp,sp,t0
     800:	70e2                	ld	ra,56(sp)
     802:	7442                	ld	s0,48(sp)
     804:	74a2                	ld	s1,40(sp)
     806:	7902                	ld	s2,32(sp)
     808:	69e2                	ld	s3,24(sp)
     80a:	6a42                	ld	s4,16(sp)
     80c:	6aa2                	ld	s5,8(sp)
     80e:	6121                	addi	sp,sp,64
     810:	8082                	ret
        int is_denied = 0;
     812:	4781                	li	a5,0
     814:	bb75                	j	5d0 <generate_compliance_report+0x118>

0000000000000816 <main>:
// =============================================================
// MAIN — Run all 12 test cases then generate report
// =============================================================
int
main(void)
{
     816:	1141                	addi	sp,sp,-16
     818:	e406                	sd	ra,8(sp)
     81a:	e022                	sd	s0,0(sp)
     81c:	0800                	addi	s0,sp,16
    printf("\n=== xv6 Medical Device Security Test Suite ===\n");
     81e:	00001517          	auipc	a0,0x1
     822:	44a50513          	addi	a0,a0,1098 # 1c68 <malloc+0xb9e>
     826:	7ec000ef          	jal	1012 <printf>
    printf("Running 12 test cases...\n\n");
     82a:	00001517          	auipc	a0,0x1
     82e:	47650513          	addi	a0,a0,1142 # 1ca0 <malloc+0xbd6>
     832:	7e0000ef          	jal	1012 <printf>

    // Must be logged in as admin to run full suite
    if (login("admin", "admin123") < 0) {
     836:	00001597          	auipc	a1,0x1
     83a:	9b258593          	addi	a1,a1,-1614 # 11e8 <malloc+0x11e>
     83e:	00001517          	auipc	a0,0x1
     842:	9ba50513          	addi	a0,a0,-1606 # 11f8 <malloc+0x12e>
     846:	3e6000ef          	jal	c2c <login>
     84a:	06054d63          	bltz	a0,8c4 <main+0xae>
        printf("ERROR: Cannot authenticate as admin. Aborting.\n");
        exit(1);
    }

    test_admin_login();
     84e:	81bff0ef          	jal	68 <test_admin_login>
    test_bad_password();
     852:	84bff0ef          	jal	9c <test_bad_password>
    test_patient_login();
     856:	87bff0ef          	jal	d0 <test_patient_login>
    test_patient_cannot_write_insulin();
     85a:	8afff0ef          	jal	108 <test_patient_cannot_write_insulin>
    test_patient_read_records();
     85e:	935ff0ef          	jal	192 <test_patient_read_records>
    test_doctor_write_insulin();
     862:	99dff0ef          	jal	1fe <test_doctor_write_insulin>
    test_patient_cannot_read_config();
     866:	a1fff0ef          	jal	284 <test_patient_cannot_read_config>
    test_doctor_cannot_read_config();
     86a:	a83ff0ef          	jal	2ec <test_doctor_cannot_read_config>
    test_patient_cannot_read_audit();
     86e:	ae7ff0ef          	jal	354 <test_patient_cannot_read_audit>
    test_admin_can_read_audit();
     872:	b43ff0ef          	jal	3b4 <test_admin_can_read_audit>
    test_patient_cannot_useradd();
     876:	b8bff0ef          	jal	400 <test_patient_cannot_useradd>
    test_nonowner_chmod_denied();
     87a:	be7ff0ef          	jal	460 <test_nonowner_chmod_denied>

    printf("\n────────────────────────────────────\n");
     87e:	00001517          	auipc	a0,0x1
     882:	47250513          	addi	a0,a0,1138 # 1cf0 <malloc+0xc26>
     886:	78c000ef          	jal	1012 <printf>
    printf("Results: %d/%d passed, %d failed\n",
     88a:	00001697          	auipc	a3,0x1
     88e:	7766a683          	lw	a3,1910(a3) # 2000 <tests_failed>
     892:	00001617          	auipc	a2,0x1
     896:	77662603          	lw	a2,1910(a2) # 2008 <tests_run>
     89a:	00001597          	auipc	a1,0x1
     89e:	76a5a583          	lw	a1,1898(a1) # 2004 <tests_passed>
     8a2:	00001517          	auipc	a0,0x1
     8a6:	4be50513          	addi	a0,a0,1214 # 1d60 <malloc+0xc96>
     8aa:	768000ef          	jal	1012 <printf>
           tests_passed, tests_run, tests_failed);
    printf("────────────────────────────────────\n");
     8ae:	00001517          	auipc	a0,0x1
     8b2:	4da50513          	addi	a0,a0,1242 # 1d88 <malloc+0xcbe>
     8b6:	75c000ef          	jal	1012 <printf>

    generate_compliance_report();
     8ba:	bffff0ef          	jal	4b8 <generate_compliance_report>

    exit(0);
     8be:	4501                	li	a0,0
     8c0:	2cc000ef          	jal	b8c <exit>
        printf("ERROR: Cannot authenticate as admin. Aborting.\n");
     8c4:	00001517          	auipc	a0,0x1
     8c8:	3fc50513          	addi	a0,a0,1020 # 1cc0 <malloc+0xbf6>
     8cc:	746000ef          	jal	1012 <printf>
        exit(1);
     8d0:	4505                	li	a0,1
     8d2:	2ba000ef          	jal	b8c <exit>

00000000000008d6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     8d6:	1141                	addi	sp,sp,-16
     8d8:	e406                	sd	ra,8(sp)
     8da:	e022                	sd	s0,0(sp)
     8dc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     8de:	f39ff0ef          	jal	816 <main>
  exit(r);
     8e2:	2aa000ef          	jal	b8c <exit>

00000000000008e6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     8e6:	1141                	addi	sp,sp,-16
     8e8:	e406                	sd	ra,8(sp)
     8ea:	e022                	sd	s0,0(sp)
     8ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     8ee:	87aa                	mv	a5,a0
     8f0:	0585                	addi	a1,a1,1
     8f2:	0785                	addi	a5,a5,1
     8f4:	fff5c703          	lbu	a4,-1(a1)
     8f8:	fee78fa3          	sb	a4,-1(a5)
     8fc:	fb75                	bnez	a4,8f0 <strcpy+0xa>
    ;
  return os;
}
     8fe:	60a2                	ld	ra,8(sp)
     900:	6402                	ld	s0,0(sp)
     902:	0141                	addi	sp,sp,16
     904:	8082                	ret

0000000000000906 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     906:	1141                	addi	sp,sp,-16
     908:	e406                	sd	ra,8(sp)
     90a:	e022                	sd	s0,0(sp)
     90c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     90e:	00054783          	lbu	a5,0(a0)
     912:	cb91                	beqz	a5,926 <strcmp+0x20>
     914:	0005c703          	lbu	a4,0(a1)
     918:	00f71763          	bne	a4,a5,926 <strcmp+0x20>
    p++, q++;
     91c:	0505                	addi	a0,a0,1
     91e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     920:	00054783          	lbu	a5,0(a0)
     924:	fbe5                	bnez	a5,914 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     926:	0005c503          	lbu	a0,0(a1)
}
     92a:	40a7853b          	subw	a0,a5,a0
     92e:	60a2                	ld	ra,8(sp)
     930:	6402                	ld	s0,0(sp)
     932:	0141                	addi	sp,sp,16
     934:	8082                	ret

0000000000000936 <strlen>:

uint
strlen(const char *s)
{
     936:	1141                	addi	sp,sp,-16
     938:	e406                	sd	ra,8(sp)
     93a:	e022                	sd	s0,0(sp)
     93c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     93e:	00054783          	lbu	a5,0(a0)
     942:	cf91                	beqz	a5,95e <strlen+0x28>
     944:	00150793          	addi	a5,a0,1
     948:	86be                	mv	a3,a5
     94a:	0785                	addi	a5,a5,1
     94c:	fff7c703          	lbu	a4,-1(a5)
     950:	ff65                	bnez	a4,948 <strlen+0x12>
     952:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     956:	60a2                	ld	ra,8(sp)
     958:	6402                	ld	s0,0(sp)
     95a:	0141                	addi	sp,sp,16
     95c:	8082                	ret
  for(n = 0; s[n]; n++)
     95e:	4501                	li	a0,0
     960:	bfdd                	j	956 <strlen+0x20>

0000000000000962 <memset>:

void*
memset(void *dst, int c, uint n)
{
     962:	1141                	addi	sp,sp,-16
     964:	e406                	sd	ra,8(sp)
     966:	e022                	sd	s0,0(sp)
     968:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     96a:	ca19                	beqz	a2,980 <memset+0x1e>
     96c:	87aa                	mv	a5,a0
     96e:	1602                	slli	a2,a2,0x20
     970:	9201                	srli	a2,a2,0x20
     972:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     976:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     97a:	0785                	addi	a5,a5,1
     97c:	fee79de3          	bne	a5,a4,976 <memset+0x14>
  }
  return dst;
}
     980:	60a2                	ld	ra,8(sp)
     982:	6402                	ld	s0,0(sp)
     984:	0141                	addi	sp,sp,16
     986:	8082                	ret

0000000000000988 <strchr>:

char*
strchr(const char *s, char c)
{
     988:	1141                	addi	sp,sp,-16
     98a:	e406                	sd	ra,8(sp)
     98c:	e022                	sd	s0,0(sp)
     98e:	0800                	addi	s0,sp,16
  for(; *s; s++)
     990:	00054783          	lbu	a5,0(a0)
     994:	cf81                	beqz	a5,9ac <strchr+0x24>
    if(*s == c)
     996:	00f58763          	beq	a1,a5,9a4 <strchr+0x1c>
  for(; *s; s++)
     99a:	0505                	addi	a0,a0,1
     99c:	00054783          	lbu	a5,0(a0)
     9a0:	fbfd                	bnez	a5,996 <strchr+0xe>
      return (char*)s;
  return 0;
     9a2:	4501                	li	a0,0
}
     9a4:	60a2                	ld	ra,8(sp)
     9a6:	6402                	ld	s0,0(sp)
     9a8:	0141                	addi	sp,sp,16
     9aa:	8082                	ret
  return 0;
     9ac:	4501                	li	a0,0
     9ae:	bfdd                	j	9a4 <strchr+0x1c>

00000000000009b0 <gets>:

char*
gets(char *buf, int max)
{
     9b0:	711d                	addi	sp,sp,-96
     9b2:	ec86                	sd	ra,88(sp)
     9b4:	e8a2                	sd	s0,80(sp)
     9b6:	e4a6                	sd	s1,72(sp)
     9b8:	e0ca                	sd	s2,64(sp)
     9ba:	fc4e                	sd	s3,56(sp)
     9bc:	f852                	sd	s4,48(sp)
     9be:	f456                	sd	s5,40(sp)
     9c0:	f05a                	sd	s6,32(sp)
     9c2:	ec5e                	sd	s7,24(sp)
     9c4:	e862                	sd	s8,16(sp)
     9c6:	1080                	addi	s0,sp,96
     9c8:	8baa                	mv	s7,a0
     9ca:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     9cc:	892a                	mv	s2,a0
     9ce:	4481                	li	s1,0
    cc = read(0, &c, 1);
     9d0:	faf40b13          	addi	s6,s0,-81
     9d4:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
     9d6:	8c26                	mv	s8,s1
     9d8:	0014899b          	addiw	s3,s1,1
     9dc:	84ce                	mv	s1,s3
     9de:	0349d463          	bge	s3,s4,a06 <gets+0x56>
    cc = read(0, &c, 1);
     9e2:	8656                	mv	a2,s5
     9e4:	85da                	mv	a1,s6
     9e6:	4501                	li	a0,0
     9e8:	1bc000ef          	jal	ba4 <read>
    if(cc < 1)
     9ec:	00a05d63          	blez	a0,a06 <gets+0x56>
      break;
    buf[i++] = c;
     9f0:	faf44783          	lbu	a5,-81(s0)
     9f4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     9f8:	0905                	addi	s2,s2,1
     9fa:	ff678713          	addi	a4,a5,-10
     9fe:	c319                	beqz	a4,a04 <gets+0x54>
     a00:	17cd                	addi	a5,a5,-13
     a02:	fbf1                	bnez	a5,9d6 <gets+0x26>
    buf[i++] = c;
     a04:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     a06:	9c5e                	add	s8,s8,s7
     a08:	000c0023          	sb	zero,0(s8)
  return buf;
}
     a0c:	855e                	mv	a0,s7
     a0e:	60e6                	ld	ra,88(sp)
     a10:	6446                	ld	s0,80(sp)
     a12:	64a6                	ld	s1,72(sp)
     a14:	6906                	ld	s2,64(sp)
     a16:	79e2                	ld	s3,56(sp)
     a18:	7a42                	ld	s4,48(sp)
     a1a:	7aa2                	ld	s5,40(sp)
     a1c:	7b02                	ld	s6,32(sp)
     a1e:	6be2                	ld	s7,24(sp)
     a20:	6c42                	ld	s8,16(sp)
     a22:	6125                	addi	sp,sp,96
     a24:	8082                	ret

0000000000000a26 <stat>:

int
stat(const char *n, struct stat *st)
{
     a26:	1101                	addi	sp,sp,-32
     a28:	ec06                	sd	ra,24(sp)
     a2a:	e822                	sd	s0,16(sp)
     a2c:	e04a                	sd	s2,0(sp)
     a2e:	1000                	addi	s0,sp,32
     a30:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a32:	4581                	li	a1,0
     a34:	198000ef          	jal	bcc <open>
  if(fd < 0)
     a38:	02054263          	bltz	a0,a5c <stat+0x36>
     a3c:	e426                	sd	s1,8(sp)
     a3e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a40:	85ca                	mv	a1,s2
     a42:	1a2000ef          	jal	be4 <fstat>
     a46:	892a                	mv	s2,a0
  close(fd);
     a48:	8526                	mv	a0,s1
     a4a:	16a000ef          	jal	bb4 <close>
  return r;
     a4e:	64a2                	ld	s1,8(sp)
}
     a50:	854a                	mv	a0,s2
     a52:	60e2                	ld	ra,24(sp)
     a54:	6442                	ld	s0,16(sp)
     a56:	6902                	ld	s2,0(sp)
     a58:	6105                	addi	sp,sp,32
     a5a:	8082                	ret
    return -1;
     a5c:	57fd                	li	a5,-1
     a5e:	893e                	mv	s2,a5
     a60:	bfc5                	j	a50 <stat+0x2a>

0000000000000a62 <atoi>:

int
atoi(const char *s)
{
     a62:	1141                	addi	sp,sp,-16
     a64:	e406                	sd	ra,8(sp)
     a66:	e022                	sd	s0,0(sp)
     a68:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     a6a:	00054683          	lbu	a3,0(a0)
     a6e:	fd06879b          	addiw	a5,a3,-48
     a72:	0ff7f793          	zext.b	a5,a5
     a76:	4625                	li	a2,9
     a78:	02f66963          	bltu	a2,a5,aaa <atoi+0x48>
     a7c:	872a                	mv	a4,a0
  n = 0;
     a7e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     a80:	0705                	addi	a4,a4,1
     a82:	0025179b          	slliw	a5,a0,0x2
     a86:	9fa9                	addw	a5,a5,a0
     a88:	0017979b          	slliw	a5,a5,0x1
     a8c:	9fb5                	addw	a5,a5,a3
     a8e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     a92:	00074683          	lbu	a3,0(a4)
     a96:	fd06879b          	addiw	a5,a3,-48
     a9a:	0ff7f793          	zext.b	a5,a5
     a9e:	fef671e3          	bgeu	a2,a5,a80 <atoi+0x1e>
  return n;
}
     aa2:	60a2                	ld	ra,8(sp)
     aa4:	6402                	ld	s0,0(sp)
     aa6:	0141                	addi	sp,sp,16
     aa8:	8082                	ret
  n = 0;
     aaa:	4501                	li	a0,0
     aac:	bfdd                	j	aa2 <atoi+0x40>

0000000000000aae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     aae:	1141                	addi	sp,sp,-16
     ab0:	e406                	sd	ra,8(sp)
     ab2:	e022                	sd	s0,0(sp)
     ab4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     ab6:	02b57563          	bgeu	a0,a1,ae0 <memmove+0x32>
    while(n-- > 0)
     aba:	00c05f63          	blez	a2,ad8 <memmove+0x2a>
     abe:	1602                	slli	a2,a2,0x20
     ac0:	9201                	srli	a2,a2,0x20
     ac2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     ac6:	872a                	mv	a4,a0
      *dst++ = *src++;
     ac8:	0585                	addi	a1,a1,1
     aca:	0705                	addi	a4,a4,1
     acc:	fff5c683          	lbu	a3,-1(a1)
     ad0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     ad4:	fee79ae3          	bne	a5,a4,ac8 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ad8:	60a2                	ld	ra,8(sp)
     ada:	6402                	ld	s0,0(sp)
     adc:	0141                	addi	sp,sp,16
     ade:	8082                	ret
    while(n-- > 0)
     ae0:	fec05ce3          	blez	a2,ad8 <memmove+0x2a>
    dst += n;
     ae4:	00c50733          	add	a4,a0,a2
    src += n;
     ae8:	95b2                	add	a1,a1,a2
     aea:	fff6079b          	addiw	a5,a2,-1
     aee:	1782                	slli	a5,a5,0x20
     af0:	9381                	srli	a5,a5,0x20
     af2:	fff7c793          	not	a5,a5
     af6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     af8:	15fd                	addi	a1,a1,-1
     afa:	177d                	addi	a4,a4,-1
     afc:	0005c683          	lbu	a3,0(a1)
     b00:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     b04:	fef71ae3          	bne	a4,a5,af8 <memmove+0x4a>
     b08:	bfc1                	j	ad8 <memmove+0x2a>

0000000000000b0a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     b0a:	1141                	addi	sp,sp,-16
     b0c:	e406                	sd	ra,8(sp)
     b0e:	e022                	sd	s0,0(sp)
     b10:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     b12:	c61d                	beqz	a2,b40 <memcmp+0x36>
     b14:	1602                	slli	a2,a2,0x20
     b16:	9201                	srli	a2,a2,0x20
     b18:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     b1c:	00054783          	lbu	a5,0(a0)
     b20:	0005c703          	lbu	a4,0(a1)
     b24:	00e79863          	bne	a5,a4,b34 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     b28:	0505                	addi	a0,a0,1
    p2++;
     b2a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b2c:	fed518e3          	bne	a0,a3,b1c <memcmp+0x12>
  }
  return 0;
     b30:	4501                	li	a0,0
     b32:	a019                	j	b38 <memcmp+0x2e>
      return *p1 - *p2;
     b34:	40e7853b          	subw	a0,a5,a4
}
     b38:	60a2                	ld	ra,8(sp)
     b3a:	6402                	ld	s0,0(sp)
     b3c:	0141                	addi	sp,sp,16
     b3e:	8082                	ret
  return 0;
     b40:	4501                	li	a0,0
     b42:	bfdd                	j	b38 <memcmp+0x2e>

0000000000000b44 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b44:	1141                	addi	sp,sp,-16
     b46:	e406                	sd	ra,8(sp)
     b48:	e022                	sd	s0,0(sp)
     b4a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b4c:	f63ff0ef          	jal	aae <memmove>
}
     b50:	60a2                	ld	ra,8(sp)
     b52:	6402                	ld	s0,0(sp)
     b54:	0141                	addi	sp,sp,16
     b56:	8082                	ret

0000000000000b58 <sbrk>:

char *
sbrk(int n) {
     b58:	1141                	addi	sp,sp,-16
     b5a:	e406                	sd	ra,8(sp)
     b5c:	e022                	sd	s0,0(sp)
     b5e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     b60:	4585                	li	a1,1
     b62:	0b2000ef          	jal	c14 <sys_sbrk>
}
     b66:	60a2                	ld	ra,8(sp)
     b68:	6402                	ld	s0,0(sp)
     b6a:	0141                	addi	sp,sp,16
     b6c:	8082                	ret

0000000000000b6e <sbrklazy>:

char *
sbrklazy(int n) {
     b6e:	1141                	addi	sp,sp,-16
     b70:	e406                	sd	ra,8(sp)
     b72:	e022                	sd	s0,0(sp)
     b74:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     b76:	4589                	li	a1,2
     b78:	09c000ef          	jal	c14 <sys_sbrk>
}
     b7c:	60a2                	ld	ra,8(sp)
     b7e:	6402                	ld	s0,0(sp)
     b80:	0141                	addi	sp,sp,16
     b82:	8082                	ret

0000000000000b84 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     b84:	4885                	li	a7,1
 ecall
     b86:	00000073          	ecall
 ret
     b8a:	8082                	ret

0000000000000b8c <exit>:
.global exit
exit:
 li a7, SYS_exit
     b8c:	4889                	li	a7,2
 ecall
     b8e:	00000073          	ecall
 ret
     b92:	8082                	ret

0000000000000b94 <wait>:
.global wait
wait:
 li a7, SYS_wait
     b94:	488d                	li	a7,3
 ecall
     b96:	00000073          	ecall
 ret
     b9a:	8082                	ret

0000000000000b9c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     b9c:	4891                	li	a7,4
 ecall
     b9e:	00000073          	ecall
 ret
     ba2:	8082                	ret

0000000000000ba4 <read>:
.global read
read:
 li a7, SYS_read
     ba4:	4895                	li	a7,5
 ecall
     ba6:	00000073          	ecall
 ret
     baa:	8082                	ret

0000000000000bac <write>:
.global write
write:
 li a7, SYS_write
     bac:	48c1                	li	a7,16
 ecall
     bae:	00000073          	ecall
 ret
     bb2:	8082                	ret

0000000000000bb4 <close>:
.global close
close:
 li a7, SYS_close
     bb4:	48d5                	li	a7,21
 ecall
     bb6:	00000073          	ecall
 ret
     bba:	8082                	ret

0000000000000bbc <kill>:
.global kill
kill:
 li a7, SYS_kill
     bbc:	4899                	li	a7,6
 ecall
     bbe:	00000073          	ecall
 ret
     bc2:	8082                	ret

0000000000000bc4 <exec>:
.global exec
exec:
 li a7, SYS_exec
     bc4:	489d                	li	a7,7
 ecall
     bc6:	00000073          	ecall
 ret
     bca:	8082                	ret

0000000000000bcc <open>:
.global open
open:
 li a7, SYS_open
     bcc:	48bd                	li	a7,15
 ecall
     bce:	00000073          	ecall
 ret
     bd2:	8082                	ret

0000000000000bd4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     bd4:	48c5                	li	a7,17
 ecall
     bd6:	00000073          	ecall
 ret
     bda:	8082                	ret

0000000000000bdc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     bdc:	48c9                	li	a7,18
 ecall
     bde:	00000073          	ecall
 ret
     be2:	8082                	ret

0000000000000be4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     be4:	48a1                	li	a7,8
 ecall
     be6:	00000073          	ecall
 ret
     bea:	8082                	ret

0000000000000bec <link>:
.global link
link:
 li a7, SYS_link
     bec:	48cd                	li	a7,19
 ecall
     bee:	00000073          	ecall
 ret
     bf2:	8082                	ret

0000000000000bf4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     bf4:	48d1                	li	a7,20
 ecall
     bf6:	00000073          	ecall
 ret
     bfa:	8082                	ret

0000000000000bfc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     bfc:	48a5                	li	a7,9
 ecall
     bfe:	00000073          	ecall
 ret
     c02:	8082                	ret

0000000000000c04 <dup>:
.global dup
dup:
 li a7, SYS_dup
     c04:	48a9                	li	a7,10
 ecall
     c06:	00000073          	ecall
 ret
     c0a:	8082                	ret

0000000000000c0c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     c0c:	48ad                	li	a7,11
 ecall
     c0e:	00000073          	ecall
 ret
     c12:	8082                	ret

0000000000000c14 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     c14:	48b1                	li	a7,12
 ecall
     c16:	00000073          	ecall
 ret
     c1a:	8082                	ret

0000000000000c1c <pause>:
.global pause
pause:
 li a7, SYS_pause
     c1c:	48b5                	li	a7,13
 ecall
     c1e:	00000073          	ecall
 ret
     c22:	8082                	ret

0000000000000c24 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     c24:	48b9                	li	a7,14
 ecall
     c26:	00000073          	ecall
 ret
     c2a:	8082                	ret

0000000000000c2c <login>:
.global login
login:
 li a7, SYS_login
     c2c:	48d9                	li	a7,22
 ecall
     c2e:	00000073          	ecall
 ret
     c32:	8082                	ret

0000000000000c34 <useradd>:
.global useradd
useradd:
 li a7, SYS_useradd
     c34:	48dd                	li	a7,23
 ecall
     c36:	00000073          	ecall
 ret
     c3a:	8082                	ret

0000000000000c3c <userdel>:
.global userdel
userdel:
 li a7, SYS_userdel
     c3c:	48e1                	li	a7,24
 ecall
     c3e:	00000073          	ecall
 ret
     c42:	8082                	ret

0000000000000c44 <passwd>:
.global passwd
passwd:
 li a7, SYS_passwd
     c44:	48e5                	li	a7,25
 ecall
     c46:	00000073          	ecall
 ret
     c4a:	8082                	ret

0000000000000c4c <whoami>:
.global whoami
whoami:
 li a7, SYS_whoami
     c4c:	48e9                	li	a7,26
 ecall
     c4e:	00000073          	ecall
 ret
     c52:	8082                	ret

0000000000000c54 <chmod>:
.global chmod
chmod:
 li a7, SYS_chmod
     c54:	48ed                	li	a7,27
 ecall
     c56:	00000073          	ecall
 ret
     c5a:	8082                	ret

0000000000000c5c <chown>:
.global chown
chown:
 li a7, SYS_chown
     c5c:	48f1                	li	a7,28
 ecall
     c5e:	00000073          	ecall
 ret
     c62:	8082                	ret

0000000000000c64 <audit_read>:
.global audit_read
audit_read:
 li a7, SYS_audit_read
     c64:	48f5                	li	a7,29
 ecall
     c66:	00000073          	ecall
 ret
     c6a:	8082                	ret

0000000000000c6c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c6c:	1101                	addi	sp,sp,-32
     c6e:	ec06                	sd	ra,24(sp)
     c70:	e822                	sd	s0,16(sp)
     c72:	1000                	addi	s0,sp,32
     c74:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c78:	4605                	li	a2,1
     c7a:	fef40593          	addi	a1,s0,-17
     c7e:	f2fff0ef          	jal	bac <write>
}
     c82:	60e2                	ld	ra,24(sp)
     c84:	6442                	ld	s0,16(sp)
     c86:	6105                	addi	sp,sp,32
     c88:	8082                	ret

0000000000000c8a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     c8a:	715d                	addi	sp,sp,-80
     c8c:	e486                	sd	ra,72(sp)
     c8e:	e0a2                	sd	s0,64(sp)
     c90:	f84a                	sd	s2,48(sp)
     c92:	f44e                	sd	s3,40(sp)
     c94:	0880                	addi	s0,sp,80
     c96:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     c98:	c6d1                	beqz	a3,d24 <printint+0x9a>
     c9a:	0805d563          	bgez	a1,d24 <printint+0x9a>
    neg = 1;
    x = -xx;
     c9e:	40b005b3          	neg	a1,a1
    neg = 1;
     ca2:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
     ca4:	fb840993          	addi	s3,s0,-72
  neg = 0;
     ca8:	86ce                	mv	a3,s3
  i = 0;
     caa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     cac:	00001817          	auipc	a6,0x1
     cb0:	15480813          	addi	a6,a6,340 # 1e00 <digits>
     cb4:	88ba                	mv	a7,a4
     cb6:	0017051b          	addiw	a0,a4,1
     cba:	872a                	mv	a4,a0
     cbc:	02c5f7b3          	remu	a5,a1,a2
     cc0:	97c2                	add	a5,a5,a6
     cc2:	0007c783          	lbu	a5,0(a5)
     cc6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     cca:	87ae                	mv	a5,a1
     ccc:	02c5d5b3          	divu	a1,a1,a2
     cd0:	0685                	addi	a3,a3,1
     cd2:	fec7f1e3          	bgeu	a5,a2,cb4 <printint+0x2a>
  if(neg)
     cd6:	00030c63          	beqz	t1,cee <printint+0x64>
    buf[i++] = '-';
     cda:	fd050793          	addi	a5,a0,-48
     cde:	00878533          	add	a0,a5,s0
     ce2:	02d00793          	li	a5,45
     ce6:	fef50423          	sb	a5,-24(a0)
     cea:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
     cee:	02e05563          	blez	a4,d18 <printint+0x8e>
     cf2:	fc26                	sd	s1,56(sp)
     cf4:	377d                	addiw	a4,a4,-1
     cf6:	00e984b3          	add	s1,s3,a4
     cfa:	19fd                	addi	s3,s3,-1
     cfc:	99ba                	add	s3,s3,a4
     cfe:	1702                	slli	a4,a4,0x20
     d00:	9301                	srli	a4,a4,0x20
     d02:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     d06:	0004c583          	lbu	a1,0(s1)
     d0a:	854a                	mv	a0,s2
     d0c:	f61ff0ef          	jal	c6c <putc>
  while(--i >= 0)
     d10:	14fd                	addi	s1,s1,-1
     d12:	ff349ae3          	bne	s1,s3,d06 <printint+0x7c>
     d16:	74e2                	ld	s1,56(sp)
}
     d18:	60a6                	ld	ra,72(sp)
     d1a:	6406                	ld	s0,64(sp)
     d1c:	7942                	ld	s2,48(sp)
     d1e:	79a2                	ld	s3,40(sp)
     d20:	6161                	addi	sp,sp,80
     d22:	8082                	ret
  neg = 0;
     d24:	4301                	li	t1,0
     d26:	bfbd                	j	ca4 <printint+0x1a>

0000000000000d28 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     d28:	711d                	addi	sp,sp,-96
     d2a:	ec86                	sd	ra,88(sp)
     d2c:	e8a2                	sd	s0,80(sp)
     d2e:	e4a6                	sd	s1,72(sp)
     d30:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     d32:	0005c483          	lbu	s1,0(a1)
     d36:	22048363          	beqz	s1,f5c <vprintf+0x234>
     d3a:	e0ca                	sd	s2,64(sp)
     d3c:	fc4e                	sd	s3,56(sp)
     d3e:	f852                	sd	s4,48(sp)
     d40:	f456                	sd	s5,40(sp)
     d42:	f05a                	sd	s6,32(sp)
     d44:	ec5e                	sd	s7,24(sp)
     d46:	e862                	sd	s8,16(sp)
     d48:	8b2a                	mv	s6,a0
     d4a:	8a2e                	mv	s4,a1
     d4c:	8bb2                	mv	s7,a2
  state = 0;
     d4e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     d50:	4901                	li	s2,0
     d52:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d54:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d58:	06400c13          	li	s8,100
     d5c:	a00d                	j	d7e <vprintf+0x56>
        putc(fd, c0);
     d5e:	85a6                	mv	a1,s1
     d60:	855a                	mv	a0,s6
     d62:	f0bff0ef          	jal	c6c <putc>
     d66:	a019                	j	d6c <vprintf+0x44>
    } else if(state == '%'){
     d68:	03598363          	beq	s3,s5,d8e <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
     d6c:	0019079b          	addiw	a5,s2,1
     d70:	893e                	mv	s2,a5
     d72:	873e                	mv	a4,a5
     d74:	97d2                	add	a5,a5,s4
     d76:	0007c483          	lbu	s1,0(a5)
     d7a:	1c048a63          	beqz	s1,f4e <vprintf+0x226>
    c0 = fmt[i] & 0xff;
     d7e:	0004879b          	sext.w	a5,s1
    if(state == 0){
     d82:	fe0993e3          	bnez	s3,d68 <vprintf+0x40>
      if(c0 == '%'){
     d86:	fd579ce3          	bne	a5,s5,d5e <vprintf+0x36>
        state = '%';
     d8a:	89be                	mv	s3,a5
     d8c:	b7c5                	j	d6c <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
     d8e:	00ea06b3          	add	a3,s4,a4
     d92:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
     d96:	1c060863          	beqz	a2,f66 <vprintf+0x23e>
      if(c0 == 'd'){
     d9a:	03878763          	beq	a5,s8,dc8 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d9e:	f9478693          	addi	a3,a5,-108
     da2:	0016b693          	seqz	a3,a3
     da6:	f9c60593          	addi	a1,a2,-100
     daa:	e99d                	bnez	a1,de0 <vprintf+0xb8>
     dac:	ca95                	beqz	a3,de0 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
     dae:	008b8493          	addi	s1,s7,8
     db2:	4685                	li	a3,1
     db4:	4629                	li	a2,10
     db6:	000bb583          	ld	a1,0(s7)
     dba:	855a                	mv	a0,s6
     dbc:	ecfff0ef          	jal	c8a <printint>
        i += 1;
     dc0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     dc2:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     dc4:	4981                	li	s3,0
     dc6:	b75d                	j	d6c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
     dc8:	008b8493          	addi	s1,s7,8
     dcc:	4685                	li	a3,1
     dce:	4629                	li	a2,10
     dd0:	000ba583          	lw	a1,0(s7)
     dd4:	855a                	mv	a0,s6
     dd6:	eb5ff0ef          	jal	c8a <printint>
     dda:	8ba6                	mv	s7,s1
      state = 0;
     ddc:	4981                	li	s3,0
     dde:	b779                	j	d6c <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
     de0:	9752                	add	a4,a4,s4
     de2:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     de6:	f9460713          	addi	a4,a2,-108
     dea:	00173713          	seqz	a4,a4
     dee:	8f75                	and	a4,a4,a3
     df0:	f9c58513          	addi	a0,a1,-100
     df4:	18051363          	bnez	a0,f7a <vprintf+0x252>
     df8:	18070163          	beqz	a4,f7a <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
     dfc:	008b8493          	addi	s1,s7,8
     e00:	4685                	li	a3,1
     e02:	4629                	li	a2,10
     e04:	000bb583          	ld	a1,0(s7)
     e08:	855a                	mv	a0,s6
     e0a:	e81ff0ef          	jal	c8a <printint>
        i += 2;
     e0e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e10:	8ba6                	mv	s7,s1
      state = 0;
     e12:	4981                	li	s3,0
        i += 2;
     e14:	bfa1                	j	d6c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
     e16:	008b8493          	addi	s1,s7,8
     e1a:	4681                	li	a3,0
     e1c:	4629                	li	a2,10
     e1e:	000be583          	lwu	a1,0(s7)
     e22:	855a                	mv	a0,s6
     e24:	e67ff0ef          	jal	c8a <printint>
     e28:	8ba6                	mv	s7,s1
      state = 0;
     e2a:	4981                	li	s3,0
     e2c:	b781                	j	d6c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e2e:	008b8493          	addi	s1,s7,8
     e32:	4681                	li	a3,0
     e34:	4629                	li	a2,10
     e36:	000bb583          	ld	a1,0(s7)
     e3a:	855a                	mv	a0,s6
     e3c:	e4fff0ef          	jal	c8a <printint>
        i += 1;
     e40:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     e42:	8ba6                	mv	s7,s1
      state = 0;
     e44:	4981                	li	s3,0
     e46:	b71d                	j	d6c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e48:	008b8493          	addi	s1,s7,8
     e4c:	4681                	li	a3,0
     e4e:	4629                	li	a2,10
     e50:	000bb583          	ld	a1,0(s7)
     e54:	855a                	mv	a0,s6
     e56:	e35ff0ef          	jal	c8a <printint>
        i += 2;
     e5a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     e5c:	8ba6                	mv	s7,s1
      state = 0;
     e5e:	4981                	li	s3,0
        i += 2;
     e60:	b731                	j	d6c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
     e62:	008b8493          	addi	s1,s7,8
     e66:	4681                	li	a3,0
     e68:	4641                	li	a2,16
     e6a:	000be583          	lwu	a1,0(s7)
     e6e:	855a                	mv	a0,s6
     e70:	e1bff0ef          	jal	c8a <printint>
     e74:	8ba6                	mv	s7,s1
      state = 0;
     e76:	4981                	li	s3,0
     e78:	bdd5                	j	d6c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e7a:	008b8493          	addi	s1,s7,8
     e7e:	4681                	li	a3,0
     e80:	4641                	li	a2,16
     e82:	000bb583          	ld	a1,0(s7)
     e86:	855a                	mv	a0,s6
     e88:	e03ff0ef          	jal	c8a <printint>
        i += 1;
     e8c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     e8e:	8ba6                	mv	s7,s1
      state = 0;
     e90:	4981                	li	s3,0
     e92:	bde9                	j	d6c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e94:	008b8493          	addi	s1,s7,8
     e98:	4681                	li	a3,0
     e9a:	4641                	li	a2,16
     e9c:	000bb583          	ld	a1,0(s7)
     ea0:	855a                	mv	a0,s6
     ea2:	de9ff0ef          	jal	c8a <printint>
        i += 2;
     ea6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     ea8:	8ba6                	mv	s7,s1
      state = 0;
     eaa:	4981                	li	s3,0
        i += 2;
     eac:	b5c1                	j	d6c <vprintf+0x44>
     eae:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
     eb0:	008b8793          	addi	a5,s7,8
     eb4:	8cbe                	mv	s9,a5
     eb6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     eba:	03000593          	li	a1,48
     ebe:	855a                	mv	a0,s6
     ec0:	dadff0ef          	jal	c6c <putc>
  putc(fd, 'x');
     ec4:	07800593          	li	a1,120
     ec8:	855a                	mv	a0,s6
     eca:	da3ff0ef          	jal	c6c <putc>
     ece:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     ed0:	00001b97          	auipc	s7,0x1
     ed4:	f30b8b93          	addi	s7,s7,-208 # 1e00 <digits>
     ed8:	03c9d793          	srli	a5,s3,0x3c
     edc:	97de                	add	a5,a5,s7
     ede:	0007c583          	lbu	a1,0(a5)
     ee2:	855a                	mv	a0,s6
     ee4:	d89ff0ef          	jal	c6c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     ee8:	0992                	slli	s3,s3,0x4
     eea:	34fd                	addiw	s1,s1,-1
     eec:	f4f5                	bnez	s1,ed8 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
     eee:	8be6                	mv	s7,s9
      state = 0;
     ef0:	4981                	li	s3,0
     ef2:	6ca2                	ld	s9,8(sp)
     ef4:	bda5                	j	d6c <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
     ef6:	008b8493          	addi	s1,s7,8
     efa:	000bc583          	lbu	a1,0(s7)
     efe:	855a                	mv	a0,s6
     f00:	d6dff0ef          	jal	c6c <putc>
     f04:	8ba6                	mv	s7,s1
      state = 0;
     f06:	4981                	li	s3,0
     f08:	b595                	j	d6c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
     f0a:	008b8993          	addi	s3,s7,8
     f0e:	000bb483          	ld	s1,0(s7)
     f12:	cc91                	beqz	s1,f2e <vprintf+0x206>
        for(; *s; s++)
     f14:	0004c583          	lbu	a1,0(s1)
     f18:	c985                	beqz	a1,f48 <vprintf+0x220>
          putc(fd, *s);
     f1a:	855a                	mv	a0,s6
     f1c:	d51ff0ef          	jal	c6c <putc>
        for(; *s; s++)
     f20:	0485                	addi	s1,s1,1
     f22:	0004c583          	lbu	a1,0(s1)
     f26:	f9f5                	bnez	a1,f1a <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
     f28:	8bce                	mv	s7,s3
      state = 0;
     f2a:	4981                	li	s3,0
     f2c:	b581                	j	d6c <vprintf+0x44>
          s = "(null)";
     f2e:	00001497          	auipc	s1,0x1
     f32:	eca48493          	addi	s1,s1,-310 # 1df8 <malloc+0xd2e>
        for(; *s; s++)
     f36:	02800593          	li	a1,40
     f3a:	b7c5                	j	f1a <vprintf+0x1f2>
        putc(fd, '%');
     f3c:	85be                	mv	a1,a5
     f3e:	855a                	mv	a0,s6
     f40:	d2dff0ef          	jal	c6c <putc>
      state = 0;
     f44:	4981                	li	s3,0
     f46:	b51d                	j	d6c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
     f48:	8bce                	mv	s7,s3
      state = 0;
     f4a:	4981                	li	s3,0
     f4c:	b505                	j	d6c <vprintf+0x44>
     f4e:	6906                	ld	s2,64(sp)
     f50:	79e2                	ld	s3,56(sp)
     f52:	7a42                	ld	s4,48(sp)
     f54:	7aa2                	ld	s5,40(sp)
     f56:	7b02                	ld	s6,32(sp)
     f58:	6be2                	ld	s7,24(sp)
     f5a:	6c42                	ld	s8,16(sp)
    }
  }
}
     f5c:	60e6                	ld	ra,88(sp)
     f5e:	6446                	ld	s0,80(sp)
     f60:	64a6                	ld	s1,72(sp)
     f62:	6125                	addi	sp,sp,96
     f64:	8082                	ret
      if(c0 == 'd'){
     f66:	06400713          	li	a4,100
     f6a:	e4e78fe3          	beq	a5,a4,dc8 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
     f6e:	f9478693          	addi	a3,a5,-108
     f72:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
     f76:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     f78:	4701                	li	a4,0
      } else if(c0 == 'u'){
     f7a:	07500513          	li	a0,117
     f7e:	e8a78ce3          	beq	a5,a0,e16 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
     f82:	f8b60513          	addi	a0,a2,-117
     f86:	e119                	bnez	a0,f8c <vprintf+0x264>
     f88:	ea0693e3          	bnez	a3,e2e <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     f8c:	f8b58513          	addi	a0,a1,-117
     f90:	e119                	bnez	a0,f96 <vprintf+0x26e>
     f92:	ea071be3          	bnez	a4,e48 <vprintf+0x120>
      } else if(c0 == 'x'){
     f96:	07800513          	li	a0,120
     f9a:	eca784e3          	beq	a5,a0,e62 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
     f9e:	f8860613          	addi	a2,a2,-120
     fa2:	e219                	bnez	a2,fa8 <vprintf+0x280>
     fa4:	ec069be3          	bnez	a3,e7a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     fa8:	f8858593          	addi	a1,a1,-120
     fac:	e199                	bnez	a1,fb2 <vprintf+0x28a>
     fae:	ee0713e3          	bnez	a4,e94 <vprintf+0x16c>
      } else if(c0 == 'p'){
     fb2:	07000713          	li	a4,112
     fb6:	eee78ce3          	beq	a5,a4,eae <vprintf+0x186>
      } else if(c0 == 'c'){
     fba:	06300713          	li	a4,99
     fbe:	f2e78ce3          	beq	a5,a4,ef6 <vprintf+0x1ce>
      } else if(c0 == 's'){
     fc2:	07300713          	li	a4,115
     fc6:	f4e782e3          	beq	a5,a4,f0a <vprintf+0x1e2>
      } else if(c0 == '%'){
     fca:	02500713          	li	a4,37
     fce:	f6e787e3          	beq	a5,a4,f3c <vprintf+0x214>
        putc(fd, '%');
     fd2:	02500593          	li	a1,37
     fd6:	855a                	mv	a0,s6
     fd8:	c95ff0ef          	jal	c6c <putc>
        putc(fd, c0);
     fdc:	85a6                	mv	a1,s1
     fde:	855a                	mv	a0,s6
     fe0:	c8dff0ef          	jal	c6c <putc>
      state = 0;
     fe4:	4981                	li	s3,0
     fe6:	b359                	j	d6c <vprintf+0x44>

0000000000000fe8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     fe8:	715d                	addi	sp,sp,-80
     fea:	ec06                	sd	ra,24(sp)
     fec:	e822                	sd	s0,16(sp)
     fee:	1000                	addi	s0,sp,32
     ff0:	e010                	sd	a2,0(s0)
     ff2:	e414                	sd	a3,8(s0)
     ff4:	e818                	sd	a4,16(s0)
     ff6:	ec1c                	sd	a5,24(s0)
     ff8:	03043023          	sd	a6,32(s0)
     ffc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1000:	8622                	mv	a2,s0
    1002:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1006:	d23ff0ef          	jal	d28 <vprintf>
}
    100a:	60e2                	ld	ra,24(sp)
    100c:	6442                	ld	s0,16(sp)
    100e:	6161                	addi	sp,sp,80
    1010:	8082                	ret

0000000000001012 <printf>:

void
printf(const char *fmt, ...)
{
    1012:	711d                	addi	sp,sp,-96
    1014:	ec06                	sd	ra,24(sp)
    1016:	e822                	sd	s0,16(sp)
    1018:	1000                	addi	s0,sp,32
    101a:	e40c                	sd	a1,8(s0)
    101c:	e810                	sd	a2,16(s0)
    101e:	ec14                	sd	a3,24(s0)
    1020:	f018                	sd	a4,32(s0)
    1022:	f41c                	sd	a5,40(s0)
    1024:	03043823          	sd	a6,48(s0)
    1028:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    102c:	00840613          	addi	a2,s0,8
    1030:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1034:	85aa                	mv	a1,a0
    1036:	4505                	li	a0,1
    1038:	cf1ff0ef          	jal	d28 <vprintf>
}
    103c:	60e2                	ld	ra,24(sp)
    103e:	6442                	ld	s0,16(sp)
    1040:	6125                	addi	sp,sp,96
    1042:	8082                	ret

0000000000001044 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1044:	1141                	addi	sp,sp,-16
    1046:	e406                	sd	ra,8(sp)
    1048:	e022                	sd	s0,0(sp)
    104a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    104c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1050:	00001797          	auipc	a5,0x1
    1054:	fc07b783          	ld	a5,-64(a5) # 2010 <freep>
    1058:	a039                	j	1066 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    105a:	6398                	ld	a4,0(a5)
    105c:	00e7e463          	bltu	a5,a4,1064 <free+0x20>
    1060:	00e6ea63          	bltu	a3,a4,1074 <free+0x30>
{
    1064:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1066:	fed7fae3          	bgeu	a5,a3,105a <free+0x16>
    106a:	6398                	ld	a4,0(a5)
    106c:	00e6e463          	bltu	a3,a4,1074 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1070:	fee7eae3          	bltu	a5,a4,1064 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
    1074:	ff852583          	lw	a1,-8(a0)
    1078:	6390                	ld	a2,0(a5)
    107a:	02059813          	slli	a6,a1,0x20
    107e:	01c85713          	srli	a4,a6,0x1c
    1082:	9736                	add	a4,a4,a3
    1084:	02e60563          	beq	a2,a4,10ae <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
    1088:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    108c:	4790                	lw	a2,8(a5)
    108e:	02061593          	slli	a1,a2,0x20
    1092:	01c5d713          	srli	a4,a1,0x1c
    1096:	973e                	add	a4,a4,a5
    1098:	02e68263          	beq	a3,a4,10bc <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
    109c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    109e:	00001717          	auipc	a4,0x1
    10a2:	f6f73923          	sd	a5,-142(a4) # 2010 <freep>
}
    10a6:	60a2                	ld	ra,8(sp)
    10a8:	6402                	ld	s0,0(sp)
    10aa:	0141                	addi	sp,sp,16
    10ac:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
    10ae:	4618                	lw	a4,8(a2)
    10b0:	9f2d                	addw	a4,a4,a1
    10b2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    10b6:	6398                	ld	a4,0(a5)
    10b8:	6310                	ld	a2,0(a4)
    10ba:	b7f9                	j	1088 <free+0x44>
    p->s.size += bp->s.size;
    10bc:	ff852703          	lw	a4,-8(a0)
    10c0:	9f31                	addw	a4,a4,a2
    10c2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    10c4:	ff053683          	ld	a3,-16(a0)
    10c8:	bfd1                	j	109c <free+0x58>

00000000000010ca <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    10ca:	7139                	addi	sp,sp,-64
    10cc:	fc06                	sd	ra,56(sp)
    10ce:	f822                	sd	s0,48(sp)
    10d0:	f04a                	sd	s2,32(sp)
    10d2:	ec4e                	sd	s3,24(sp)
    10d4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    10d6:	02051993          	slli	s3,a0,0x20
    10da:	0209d993          	srli	s3,s3,0x20
    10de:	09bd                	addi	s3,s3,15
    10e0:	0049d993          	srli	s3,s3,0x4
    10e4:	2985                	addiw	s3,s3,1
    10e6:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
    10e8:	00001517          	auipc	a0,0x1
    10ec:	f2853503          	ld	a0,-216(a0) # 2010 <freep>
    10f0:	c905                	beqz	a0,1120 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10f2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10f4:	4798                	lw	a4,8(a5)
    10f6:	09377663          	bgeu	a4,s3,1182 <malloc+0xb8>
    10fa:	f426                	sd	s1,40(sp)
    10fc:	e852                	sd	s4,16(sp)
    10fe:	e456                	sd	s5,8(sp)
    1100:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1102:	8a4e                	mv	s4,s3
    1104:	6705                	lui	a4,0x1
    1106:	00e9f363          	bgeu	s3,a4,110c <malloc+0x42>
    110a:	6a05                	lui	s4,0x1
    110c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1110:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1114:	00001497          	auipc	s1,0x1
    1118:	efc48493          	addi	s1,s1,-260 # 2010 <freep>
  if(p == SBRK_ERROR)
    111c:	5afd                	li	s5,-1
    111e:	a83d                	j	115c <malloc+0x92>
    1120:	f426                	sd	s1,40(sp)
    1122:	e852                	sd	s4,16(sp)
    1124:	e456                	sd	s5,8(sp)
    1126:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    1128:	00001797          	auipc	a5,0x1
    112c:	ef878793          	addi	a5,a5,-264 # 2020 <base>
    1130:	00001717          	auipc	a4,0x1
    1134:	eef73023          	sd	a5,-288(a4) # 2010 <freep>
    1138:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    113a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    113e:	b7d1                	j	1102 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    1140:	6398                	ld	a4,0(a5)
    1142:	e118                	sd	a4,0(a0)
    1144:	a899                	j	119a <malloc+0xd0>
  hp->s.size = nu;
    1146:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    114a:	0541                	addi	a0,a0,16
    114c:	ef9ff0ef          	jal	1044 <free>
  return freep;
    1150:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    1152:	c125                	beqz	a0,11b2 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1154:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1156:	4798                	lw	a4,8(a5)
    1158:	03277163          	bgeu	a4,s2,117a <malloc+0xb0>
    if(p == freep)
    115c:	6098                	ld	a4,0(s1)
    115e:	853e                	mv	a0,a5
    1160:	fef71ae3          	bne	a4,a5,1154 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
    1164:	8552                	mv	a0,s4
    1166:	9f3ff0ef          	jal	b58 <sbrk>
  if(p == SBRK_ERROR)
    116a:	fd551ee3          	bne	a0,s5,1146 <malloc+0x7c>
        return 0;
    116e:	4501                	li	a0,0
    1170:	74a2                	ld	s1,40(sp)
    1172:	6a42                	ld	s4,16(sp)
    1174:	6aa2                	ld	s5,8(sp)
    1176:	6b02                	ld	s6,0(sp)
    1178:	a03d                	j	11a6 <malloc+0xdc>
    117a:	74a2                	ld	s1,40(sp)
    117c:	6a42                	ld	s4,16(sp)
    117e:	6aa2                	ld	s5,8(sp)
    1180:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1182:	fae90fe3          	beq	s2,a4,1140 <malloc+0x76>
        p->s.size -= nunits;
    1186:	4137073b          	subw	a4,a4,s3
    118a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    118c:	02071693          	slli	a3,a4,0x20
    1190:	01c6d713          	srli	a4,a3,0x1c
    1194:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1196:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    119a:	00001717          	auipc	a4,0x1
    119e:	e6a73b23          	sd	a0,-394(a4) # 2010 <freep>
      return (void*)(p + 1);
    11a2:	01078513          	addi	a0,a5,16
  }
}
    11a6:	70e2                	ld	ra,56(sp)
    11a8:	7442                	ld	s0,48(sp)
    11aa:	7902                	ld	s2,32(sp)
    11ac:	69e2                	ld	s3,24(sp)
    11ae:	6121                	addi	sp,sp,64
    11b0:	8082                	ret
    11b2:	74a2                	ld	s1,40(sp)
    11b4:	6a42                	ld	s4,16(sp)
    11b6:	6aa2                	ld	s5,8(sp)
    11b8:	6b02                	ld	s6,0(sp)
    11ba:	b7f5                	j	11a6 <malloc+0xdc>
