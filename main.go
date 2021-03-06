package main

import (
	"github.com/my-stocks-pro/earnings-scheduler/scheduler"
	"net/http"
	"log"
	"os"
	"os/signal"
	"context"
	"time"
)

func main() {
	Scheduler := scheduler.New()

	go Scheduler.Routing()

	go func() {
		if err := Scheduler.Server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()

	signal.Notify(Scheduler.QuitOS, os.Interrupt)
	select {
	case <-Scheduler.QuitOS:
		log.Println("Shutdown Server by OS signal...")
	case <-Scheduler.QuitRPC:
		log.Println("Shutdown Server by RPC signal...")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := Scheduler.Server.Shutdown(ctx); err != nil {
		log.Fatal("Server Shutdown: ", err)
	}

	log.Println("Server exiting")
}
