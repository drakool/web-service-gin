package main

import (
    "net/http"
    "os"
    "log"
    "github.com/gin-gonic/gin"
    "example/web-service-gin/loader/env"
)

// album represents data about a record album.
type album struct {
    ID     string  `json:"id"`
    Title  string  `json:"title"`
    Artist string  `json:"artist"`
    Price  float64 `json:"price"`
}


// albums slice to seed record album data.
var albums = []album{
    {ID: "1", Title: "Blue Train", Artist: "John Coltrane", Price: 56.99},
    {ID: "2", Title: "Jeru", Artist: "Gerry Mulligan", Price: 17.99},
    {ID: "3", Title: "Sarah Vaughan and Clifford Brown", Artist: "Sarah Vaughan", Price: 39.99},
}

// getAlbums responds with the list of all albums as JSON.
func getAlbums(c *gin.Context) {
    c.IndentedJSON(http.StatusOK, albums)
}

func init() {

 inits.LoadEnv()
}

func respondWithError(c *gin.Context, code int, message interface{}) {
  c.AbortWithStatusJSON(code, gin.H{"error": message})
}

func TokenAuthMiddleware() gin.HandlerFunc {
  requiredToken := os.Getenv("API_TOKEN")

  // We want to make sure the token is set, bail if not
  if requiredToken == "" {
    log.Fatal("Please set API_TOKEN environment variable")
  }

  return func(c *gin.Context) {
    apiToken := c.Request.Header.Get("api_token")
    

    if apiToken== ""{
        respondWithError(c,401,"API token required")
        return
    }
    if apiToken != requiredToken{
        respondWithError(c,401,"Invalid API token")
        return
    }

    c.Next()
  }
}


  
func main() {
    router := gin.Default()
    router.Use(TokenAuthMiddleware())
    router.GET("/albums", getAlbums)
    port :=os.Getenv("PORT")
    router.Run("0.0.0.0:"+port)
}