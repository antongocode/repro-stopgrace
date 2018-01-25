package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	grace := flag.Duration("grace", 90*time.Second, "Set the grace period")

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, os.Interrupt, syscall.SIGTERM)

	go func() {
		s := <-signals
		log.Printf("Signal %v received, sleeping for %v", s, *grace)
		time.Sleep(*grace)
		log.Print("Exit")
		os.Exit(0)
	}()

	log.Print("Starting new server")

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
	})
	http.ListenAndServe(":8087", nil)
}
