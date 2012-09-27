#!/bin/sh

make qemu-nox > jos.out &
sleep 2
kill -9 `ps aux | grep nographic | grep -v grep | awk '{print $2}'`


qemuopts="-hda obj/kern/kernel.img"
qemuphys=1
. ./grade-functions.sh


$make
#run

score=0

	echo_n "Printf: "
	if grep "6828 decimal is 15254 octal!" jos.out >/dev/null
	then
		score=`expr 10 + $score`
		echo OK $time
	else
		echo WRONG $time
	fi
    
    	if grep "chnum1: 28 chnum2: 29" jos.out > /dev/null && grep "error! writing through NULL pointer! (%n argument)" jos.out > /dev/null && grep "warning! The value %n argument pointed to has been overflowed!" jos.out > /dev/null && grep "chnum1: -1" jos.out > /dev/null
   	then 
        	score=`expr 20 + $score`
        	echo OK $time
    	else
        	echo WRONG $time
    	fi

	echo_n "Backtrace: "
	args=`grep "ebp f01.* eip f0100.* args" jos.out | awk '{ print $6 }'`
	cnt=`echo $args | grep '^00000000 00000000 00000001 00000002 00000003 00000004 00000005' | wc -w`
	if [ $cnt -eq 8 ]
	then
		score=`expr 10 + $score`
		echo_n "Count OK"
	else
		echo_n "Count WRONG"
	fi

	cnt=`grep "ebp f01.* eip f0100.* args" jos.out | awk 'BEGIN { FS = ORS = " " }
{ print $6 }
END { printf("\n") }' | grep '^00000000 00000000 00000001 00000002 00000003 00000004 00000005' | wc -w`
	if [ $cnt -eq 8 ]; then
		score=`expr 10 + $score`
		echo_n ', Args OK'
	else
		echo_n ', Args WRONG (' $args ')'
	fi

	syms=`grep "kern/init.c:.* test_backtrace" jos.out`
	symcnt=`grep "kern/init.c:.* test_backtrace" jos.out | wc -l`
	if [ $symcnt -eq 6 ]; then
		score=`expr 10 + $score`
		echo , Symbols OK $time
	else
		echo , Symbols WRONG "($syms)" $time
	fi

        if grep -A5 "leaving test_backtrace 0" jos.out | grep -A4 "leaving test_backtrace 3" | grep -A3 "leaving test_backtrace 2"| grep -A2 "leaving test_backtrace 3"| grep "leaving test_backtrace 5" > /dev/null
   	 then 
       		 score=`expr 10 + $score`
       		 echo OK $time
   	 else
       		 echo WRONG $time
    	fi


echo "Score: $score/70"


