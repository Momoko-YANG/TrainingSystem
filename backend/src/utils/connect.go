package utils

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

var Db *sql.DB

func Connect() {
	dsn := os.Getenv("MYSQL_DSN")
	if dsn == "" {
		dsn = "root:@tcp(127.0.0.1:3306)/school?charset=utf8&parseTime=true"
	}

	tmp, err := sql.Open("mysql", dsn)
	if err != nil {
		fmt.Fprintf(os.Stderr, "connecting: %v\n", err)
		os.Exit(1)
	}

	if err := tmp.Ping(); err != nil {
		fmt.Fprintf(os.Stderr, "ping database: %v\n", err)
		os.Exit(1)
	}

	Db = tmp
}
