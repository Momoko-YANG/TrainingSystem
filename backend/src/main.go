package main

import (
	"log"
	"net/http"
	"taas/router"
	"taas/utils"
)

func main() {
	utils.Connect()
	router.Build()
	err := http.ListenAndServe(":9090", nil) // Set the listening port
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
