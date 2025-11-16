package utils

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

var Db *sql.DB

func Connect() {
	// 连接本地 MySQL 数据库
	// 格式：用户名:密码@tcp(主机:端口)/数据库名?charset=utf8
	tmp, err := sql.Open("mysql", "root:@tcp(127.0.0.1:3306)/school?charset=utf8")
	if err != nil {
		fmt.Fprintf(os.Stderr, "connecting: %v\n", err)
		os.Exit(1)
	}
	Db = tmp
}
