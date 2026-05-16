package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"time"
)

type LogEntry struct {
	Time     string `json:"time"`
	Method   string `json:"method"`
	Path     string `json:"path"`
	Response string `json:"response"`
}

var (
	logs []LogEntry
	mu   sync.Mutex
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	entry := LogEntry{
		Time:     time.Now().Format("2006-01-02 15:04:05"),
		Method:   r.Method,
		Path:     r.URL.Path,
		Response: "Healthcheck OK",
	}

	mu.Lock()
	logs = append(logs, entry)
	mu.Unlock()

	fmt.Printf("[%s] %s %s -> %s\n",
		entry.Time,
		entry.Method,
		entry.Path,
		entry.Response,
	)

	w.Header().Set("Content-Type", "text/plain")
	w.Write([]byte("PONG"))
}

func logsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "application/json")
	mu.Lock()
	defer mu.Unlock()
	json.NewEncoder(w).Encode(logs)
}

func main() {

	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/logs", logsHandler)

	fs := http.FileServer(http.Dir("./src/frontend"))
	http.Handle("/", fs)

	fmt.Println("Servidor arriba en http://localhost")

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}
