package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
	"os"
)

func main() {
	r := gin.Default()

	env := os.Getenv("DEMO_ENVIRONMENT")
	version := os.Getenv("DEMO_VERSION")
	bind := os.Getenv("DEMO_BIND")
	isCanary := os.Getenv("DEMO_IS_CANARY")
	podName := os.Getenv("DEMO_POD_NAME")
	nodeName := os.Getenv("DEMO_NODE_NAME")
	if isCanary != "true" {
		isCanary = "false"
	} else {
		version = fmt.Sprintf("%s-canary", version)
	}

	r.LoadHTMLGlob("templates/*")

	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.tmpl", gin.H{
			"version":     version,
			"environment": env,
			"isCanary":    isCanary,
			"podName":     podName,
			"nodeName":    nodeName,
		})
	})

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	r.Run(bind)
}
