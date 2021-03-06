#!/bin/bash
# add 2016-11-22 by Jan Gerhards, released under ASL 2.0

uname
if [ `uname` = "FreeBSD" ] ; then
   echo "This test currently does not work on FreeBSD."
   exit 77
fi

. $srcdir/diag.sh init
. $srcdir/diag.sh generate-conf
. $srcdir/diag.sh add-conf '
template(name="outfmt" type="string" string="%msg%\n")

module(load="../plugins/mmanon/.libs/mmanon")
module(load="../plugins/imtcp/.libs/imtcp")
input(type="imtcp" port="13514" ruleset="testing")

ruleset(name="testing") {
	action(type="mmanon" ipv4.bits="33" ipv4.mode="simple" ipv4.replacechar="*")
	action(type="omfile" file="rsyslog.out.log" template="outfmt")
}
action(type="omfile" file="rsyslog2.out.log")'

. $srcdir/diag.sh startup
. $srcdir/diag.sh tcpflood -m1 -M "\"<129>Mar 10 01:00:00 172.20.245.8 tag: asdfghjk
<129>Mar 10 01:00:00 172.20.245.8 tag: before 172.9.6.4
<129>Mar 10 01:00:00 172.20.245.8 tag: 75.123.123.0 after
<129>Mar 10 01:00:00 172.20.245.8 tag: before 181.23.1.4 after
<129>Mar 10 01:00:00 172.20.245.8 tag: nothingnothingnothing
<129>Mar 10 01:00:00 172.20.245.8 tag: before 181.23.1.4 after 172.1.3.45
<129>Mar 10 01:00:00 172.20.245.8 tag: 1.1.1.8
<129>Mar 10 01:00:00 172.20.245.8 tag: 1.12.1.8
<129>Mar 10 01:00:00 172.20.245.8 tag: 1.1.1.9
<129>Mar 10 01:00:00 172.20.245.8 tag: 0.0.0.0
<129>Mar 10 01:00:00 172.20.245.8 tag: 1.2.3.4.5.6.7.8.76
<129>Mar 10 01:00:00 172.20.245.8 tag: 172.0.234.255
<129>Mar 10 01:00:00 172.20.245.8 tag: 1.0.0.0
<129>Mar 10 01:00:00 172.20.245.8 tag: 1.225.225.225
<129>Mar 10 01:00:00 172.20.245.8 tag: 172.0.234.255
<129>Mar 10 01:00:00 172.20.245.8 tag: 3.4.5.6
<129>Mar 10 01:00:00 172.20.245.8 tag: 256.0.0.0
<129>Mar 10 01:00:00 172.20.245.8 tag: 1....1....1....8
<129>Mar 10 01:00:00 172.20.245.8 tag: 1..1..1..8
<129>Mar 10 01:00:00 172.20.245.8 tag: 1..1.1.8
<129>Mar 10 01:00:00 172.20.245.8 tag: 1.1..1.8
<129>Mar 10 01:00:00 172.20.245.8 tag: 1.1.1..8
<129>Mar 10 01:00:00 172.20.245.8 tag: 1111.1.1.8.1
<129>Mar 10 01:00:00 172.20.245.8 tag: 111.1.1.8.1
<129>Mar 10 01:00:00 172.20.245.8 tag: 111.1.1.8.
<129>Mar 10 01:00:00 172.20.245.8 tag: textnoblank1.1.31.9stillnoblank\""

. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown
echo ' asdfghjk
 before ***.*.*.*
 **.***.***.* after
 before ***.**.*.* after
 nothingnothingnothing
 before ***.**.*.* after ***.*.*.**
 *.*.*.*
 *.**.*.*
 *.*.*.*
 *.*.*.*
 *.*.*.*.*.*.*.*.76
 ***.*.***.***
 *.*.*.*
 *.***.***.***
 ***.*.***.***
 *.*.*.*
 ***.*.*.*
 1....1....1....8
 1..1..1..8
 1..1.1.8
 1.1..1.8
 1.1.1..8
 ****.*.*.*.1
 ***.*.*.*.1
 ***.*.*.*.
 textnoblank*.*.**.*stillnoblank' | cmp rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid response generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  . $srcdir/diag.sh error-exit  1
fi;

grep 'invalid number of ipv4.bits (33), corrected to 32' rsyslog2.out.log > /dev/null
if [ $? -ne 0 ]; then
  echo "invalid response generated, rsyslog2.out.log is:"
  cat rsyslog2.out.log
  . $srcdir/diag.sh error-exit  1
fi;

. $srcdir/diag.sh exit
