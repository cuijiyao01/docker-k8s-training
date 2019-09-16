// based on https://golang.org/doc/articles/wiki/final.go

package main

import (
	"html/template"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
	"regexp"
	"syscall"
)

type Page struct {
	Title string
	Body  []byte
}

func (p *Page) save() error {
	filename := "data/" + p.Title + ".txt"
	return ioutil.WriteFile(filename, p.Body, 0600)
}

func loadPage(title string) (*Page, error) {
	filename := "data/" + title + ".txt"
	body, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	return &Page{Title: title, Body: body}, nil
}

func viewHandler(w http.ResponseWriter, r *http.Request, title string) {
	p, err := loadPage(title)
	if err != nil {
		http.Redirect(w, r, "/edit/"+title, http.StatusFound)
		return
	}
	renderTemplate(w, "view", p)
}

func editHandler(w http.ResponseWriter, r *http.Request, title string) {
	p, err := loadPage(title)
	if err != nil {
		p = &Page{Title: title}
	}
	renderTemplate(w, "edit", p)
}

func saveHandler(w http.ResponseWriter, r *http.Request, title string) {
	body := r.FormValue("body")
	p := &Page{Title: title, Body: []byte(body)}
	err := p.save()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/view/"+title, http.StatusFound)
}

// Idea: wrap panic with defer & recover
// in recovery mode:
// -- write files to disk
// -- parse again
func recoverToCreateHTMLTemplate() {
	if r := recover(); r != nil {
		log.Println("Error loading templates from file. Defaulting back to built-in templates.")

		editHTML, _ := os.Create("tmpl/edit.html")
		defer editHTML.Close()

		editHTML.WriteString(`<h1>Editing {{.Title}}</h1><form action="/save/{{.Title}}" method="POST"><div><textarea name="body" rows="20" cols="80">{{printf "%s" .Body}}</textarea></div> <div><input type="submit" value="Save"></div></form>`)
		editHTML.Sync()

		viewHTML, _ := os.Create("tmpl/view.html")
		defer viewHTML.Close()

		viewHTML.WriteString(`<h1>{{.Title}}</h1><p>[<a href="/edit/{{.Title}}">edit</a>]</p><div>{{printf "%s" .Body}}</div>`)
		viewHTML.Sync()

		templates = template.Must(template.ParseFiles("tmpl/edit.html", "tmpl/view.html"))
	}
}

var templates *template.Template = nil

func renderTemplate(w http.ResponseWriter, tmpl string, p *Page) {
	err := templates.ExecuteTemplate(w, tmpl+".html", p)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

var validPath = regexp.MustCompile("^/(edit|save|view)/([a-zA-Z0-9]+)$")

func makeHandler(fn func(http.ResponseWriter, *http.Request, string)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s to %s with %s.", r.RemoteAddr, r.RequestURI, r.UserAgent())
		m := validPath.FindStringSubmatch(r.URL.Path)
		if m == nil {
			http.NotFound(w, r)
			return
		}
		fn(w, r, m[2])
	}
}

func loadTemplates() {
	defer recoverToCreateHTMLTemplate()
	templates = template.Must(template.ParseFiles("tmpl/edit.html", "tmpl/view.html"))
}

func main() {

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGHUP)

	log.Println("Loading templates...")
	loadTemplates()

	go func() {
		for {
			<-sig
			log.Println("received SIG HUP - reload tempaltes...")
			loadTemplates()
		}
	}()

	log.Println("Initializing handler functions...")
	http.HandleFunc("/view/", makeHandler(viewHandler))
	http.HandleFunc("/edit/", makeHandler(editHandler))
	http.HandleFunc("/save/", makeHandler(saveHandler))
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { http.Redirect(w, r, "/view/welcome", http.StatusFound) })

	log.Println("Running webserver ...")
	log.Fatal(http.ListenAndServe(":8080", nil))

}
