package utils

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

var Db *sql.DB

func Connect() {
	// Connect to local MySQL database
	// Format: username:password@tcp(host:port)/database?charset=utf8
	tmp, err := sql.Open("mysql", "root:@tcp(127.0.0.1:3306)/school?charset=utf8mb4")
	if err != nil {
		fmt.Fprintf(os.Stderr, "connecting: %v\n", err)
		os.Exit(1)
	}
	Db = tmp
}
