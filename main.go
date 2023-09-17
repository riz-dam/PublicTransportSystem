package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
)

const (
	dbHost     = "127.0.0.1"
	dbPort     = 5432
	dbUser     = "mes"
	dbPassword = "mes"
	dbName     = "transportplatform"
	secretKey  = "MKP"
)

var db *sql.DB

func main() {
	initDB()

	r := mux.NewRouter()
	r.HandleFunc("/login", loginHandler).Methods("POST")
	r.HandleFunc("/data/{id}", getDataHandler).Methods("GET")

	fmt.Println("Server started at :8080")
	http.ListenAndServe(":8080", r)
}

func initDB() {
	// Create a PostgreSQL database connection
	connStr := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", dbHost, dbPort, dbUser, dbPassword, dbName)
	var err error
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		panic(err)
	}
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	// Generate a JWT token upon successful authentication
	token, err := createToken("your-username")
	if err != nil {
		http.Error(w, "Failed to create token", http.StatusInternalServerError)
		return
	}

	// Send the token as JSON response
	responseJSON := fmt.Sprintf(`{"token":"%s"}`, token)
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(responseJSON))
}

func getDataHandler(w http.ResponseWriter, r *http.Request) {
	// Authenticate the request using JWT
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte(secretKey), nil
	})

	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	if !token.Valid {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	// Get the 'id' parameter from the request URL
	vars := mux.Vars(r)
	id := vars["id"]

	// Retrieve specific data from the database based on 'id'
	data, err := fetchDataFromDatabase(id)
	if err != nil {
		http.Error(w, "Failed to fetch data"+err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
}

func fetchDataFromDatabase(id string) ([]Terminals, error) {
	//get data
	rows, err := db.Query("SELECT terminal_id,name FROM terminals WHERE terminal_id = $1", id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var data []Terminals

	for rows.Next() {
		var item Terminals
		err := rows.Scan(&item.Terminal_id, &item.Name)
		if err != nil {
			return nil, err
		}
		data = append(data, item)
	}
	return data, nil
}

type Terminals struct {
	Terminal_id int    `json:"terminal_id"`
	Name        string `json:"name"`
}

func createToken(username string) (string, error) {
	token := jwt.New(jwt.SigningMethodHS256)
	claims := token.Claims.(jwt.MapClaims)
	claims["username"] = username
	claims["exp"] = time.Now().Add(time.Minute * 15).Unix() // Token expires in 15 minutes

	tokenString, err := token.SignedString([]byte(secretKey))
	if err != nil {
		return "", err
	}
	return tokenString, nil
}
