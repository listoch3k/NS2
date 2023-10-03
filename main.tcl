# Создаем объект типа Simulator
set ns [new Simulator] 

#
# Create a simple six node topology:
#
#        s1                 s3
#         \                 /
# 10Mb,2ms \  1.5Mb,20ms   / 10Mb,4ms
#           r1 --------- r2
# 10Mb,3ms /               \ 10Mb,5ms
#         /                 \
#        s2                 s4 
#

# Создаем узлы s1, s2, r1, r2, s3, s4 в соответствии с топологией сети
set node_(s1) [$ns node] 
set node_(s2) [$ns node]
set node_(r1) [$ns node]
set node_(r2) [$ns node]
set node_(s3) [$ns node]
set node_(s4) [$ns node]

# Описываем соединения между узлами сети
# Соединяем узлы s1 -> r1 дуплексным соединением с пропускной способностью 10 Мб/сек и задержкой 2 мс
$ns duplex-link $node_(s1) $node_(r1) 10Mb 2ms DropTail 
# Соединяем узлы s2 -> r1 дуплексным соединением с пропускной способностью 10 Мб/сек и задержкой 3 мс
# Опцией DropTail устанавливаем, что в случае переполнения очереди - последний прибывший пакет отбрасывается
$ns duplex-link $node_(s2) $node_(r1) 10Mb 3ms DropTail 

# Соединяем узлы r1 -> r2 дуплексным соединением с пропускной способностью 1,5 Мб/сек и задержкой 20 мс, устанавливаем RED в качестве метода управления очередью устанавливаем RED
$ns duplex-link $node_(r1) $node_(r2) 1.5Mb 20ms RED 

# Устанвливаем лимит очереди для соединений r1 <-> r2 в 25 единиц
$ns queue-limit $node_(r1) $node_(r2) 25

$ns queue-limit $node_(r2) $node_(r1) 25


# Соединяем узлы s2 -> r2 дуплексным соединением с пропускной способностью 10 Мб/сек и задержкой 4 мс и опцией DropTail
# Соединяем узлы s2 -> r2 дуплексным соединением с пропускной способностью 10 Мб/сек и задержкой 5 мс и опцией DropTail
$ns duplex-link $node_(s3) $node_(r2) 10Mb 4ms DropTail 
$ns duplex-link $node_(s4) $node_(r2) 10Mb 5ms DropTail 

set tcp1 [$ns create-connection TCP/Reno $node_(s1) TCPSink $node_(s3) 0]
$tcp1 set window_ 15
set tcp2 [$ns create-connection TCP/Reno $node_(s2) TCPSink $node_(s3) 1]
$tcp2 set window_ 15
set ftp1 [$tcp1 attach-source FTP]
set ftp2 [$tcp2 attach-source FTP]

# Tracing a queue
set redq [[$ns link $node_(r1) $node_(r2)] queue]
set tchan_ [open all.q w]
$tcp1 trace cwnd_
$redq trace curq_
$redq trace ave_
$tcp1 attach $tchan_
$redq attach $tchan_


$ns at 0.0 "$ftp1 start"
$ns at 3.0 "$ftp2 start"
$ns at 10 "finish"

# Define 'finish' procedure (include post-simulation processes)
proc finish {} {
    global tchan_
    set awkCode {
	{
	    if ($1 == "Q" && NF>2) {
		print $2, $3 >> "temp.q";
		set end $2
	    }
	    if ($1 == "a" && NF>2) {
	    print $2, $3 >> "temp.a";
        }
        else if ($6 == "cwnd_")
        print $1, $7 >> "temp.c";
	}
    }
    set f [open temp.queue w]
    puts $f "TitleText: red"
    puts $f "Device: Postscript"
    
    if { [info exists tchan_] } {
	close $tchan_
    }
    exec rm -f temp.q temp.a temp.c
    exec touch temp.a temp.q temp.c
    
    exec awk $awkCode all.q
    
    puts $f \"queue
    exec cat temp.q >@ $f  
    puts $f \n\"ave_queue
    exec cat temp.a >@ $f
    puts $f \n\"cwnd
    exec cat temp.c >@ $f
    close $f
    # exec xgraph -bb -tk -x time -y queue temp.queue &
    exit 0
}

$ns run

