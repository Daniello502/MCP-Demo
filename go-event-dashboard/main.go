package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/watch"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"go-event-dashboard/internal/eventbuffer"
)

type KubeEvent = eventbuffer.KubeEvent



var eventBuf *eventbuffer.Buffer
var eventBufferSize = 100

var eventCounter = prometheus.NewCounterVec(
       prometheus.CounterOpts{
	       Name: "kube_event_total",
	       Help: "Total number of Kubernetes events received",
       },
       []string{"resource", "type", "namespace"},
)



func main() {
       prometheus.MustRegister(eventCounter)

       if sz := os.Getenv("EVENT_BUFFER_SIZE"); sz != "" {
	       if n, err := strconv.Atoi(sz); err == nil && n > 0 {
		       eventBufferSize = n
	       }
       }

       eventBuf = eventbuffer.NewBuffer(eventBufferSize)

       var config *rest.Config
       var err error
       kubeconfig := os.Getenv("KUBECONFIG")
       if kubeconfig == "" {
	       kubeconfig = os.ExpandEnv("$HOME/.kube/config")
       }
       if _, err := os.Stat(kubeconfig); err == nil {
	       config, err = rest.InClusterConfig()
	       if err != nil {
		       config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)
		       if err != nil {
			       log.Fatalf("Failed to get kubeconfig: %v", err)
		       }
	       }
       } else {
	       config, err = rest.InClusterConfig()
	       if err != nil {
		       log.Fatalf("Failed to get in-cluster config: %v", err)
	       }
       }
       clientset, err := kubernetes.NewForConfig(config)
       if err != nil {
	       log.Fatalf("Failed to create clientset: %v", err)
       }

       go watchResourceEvents(clientset)

       http.HandleFunc("/events", basicAuth(func(w http.ResponseWriter, r *http.Request) {
	       w.Header().Set("Content-Type", "application/json")
	       resource := r.URL.Query().Get("resource")
	       eventType := r.URL.Query().Get("type")
	       namespace := r.URL.Query().Get("namespace")
	       filtered := []KubeEvent{}
	       for _, e := range eventBuf.GetAll() {
		       if (resource == "" || e.Resource == resource) &&
			  (eventType == "" || e.Type == eventType) &&
			  (namespace == "" || e.Namespace == namespace) {
			       filtered = append(filtered, e)
		       }
	       }
	       json.NewEncoder(w).Encode(filtered)
       }))

       http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
	       w.WriteHeader(http.StatusOK)
	       w.Write([]byte("ok"))
       })

       http.Handle("/metrics", promhttp.Handler())

       http.HandleFunc("/stats", basicAuth(func(w http.ResponseWriter, r *http.Request) {
	       stats := map[string]int{}
	       for _, e := range eventBuf.GetAll() {
		       key := fmt.Sprintf("%s:%s:%s", e.Resource, e.Type, e.Namespace)
		       stats[key]++
	       }
	       w.Header().Set("Content-Type", "application/json")
	       json.NewEncoder(w).Encode(stats)
       }))

       port := os.Getenv("PORT")
       if port == "" {
	       port = "8080"
       }
       log.Printf("Starting server on :%s", port)
       log.Fatal(http.ListenAndServe(":"+port, nil))
}


func watchResourceEvents(clientset *kubernetes.Clientset) {
       resources := []struct {
	       name string
	       getWatcher func() (watch.Interface, error)
       }{
	       {"Pod", func() (watch.Interface, error) {
		       return clientset.CoreV1().Pods("").Watch(context.TODO(), metav1.ListOptions{})
	       }},
	       {"Service", func() (watch.Interface, error) {
		       return clientset.CoreV1().Services("").Watch(context.TODO(), metav1.ListOptions{})
	       }},
	       {"Deployment", func() (watch.Interface, error) {
		       return clientset.AppsV1().Deployments("").Watch(context.TODO(), metav1.ListOptions{})
	       }},
	       // Add more resources here if needed
       }
       for _, r := range resources {
	       go watchGeneric(clientset, r.name, r.getWatcher)
       }
}


func watchGeneric(clientset *kubernetes.Clientset, resource string, getWatcher func() (watch.Interface, error)) {
       watcher, err := getWatcher()
       if err != nil {
	       log.Printf("Failed to start watcher for %s: %v", resource, err)
	       return
       }
       for event := range watcher.ResultChan() {
	       metaObj, ok := event.Object.(metav1.Object)
	       ns, name := "", ""
	       if ok {
		       ns = metaObj.GetNamespace()
		       name = metaObj.GetName()
	       }
	       ke := KubeEvent{
		       Resource:  resource,
		       Type:      string(event.Type),
		       Namespace: ns,
		       Name:      name,
		       Object:    event.Object,
		       Time:      time.Now(),
	       }
	       if ke.Type == "ADDED" || ke.Type == "MODIFIED" || ke.Type == "DELETED" {
		       eventCounter.WithLabelValues(resource, ke.Type, ns).Inc()
		       eventBuf.Add(ke)
	       }
       }
}

// basicAuth is a simple middleware for HTTP Basic Auth
func basicAuth(next http.HandlerFunc) http.HandlerFunc {
       return func(w http.ResponseWriter, r *http.Request) {
	       user, pass, ok := r.BasicAuth()
	       expectedUser := os.Getenv("DASH_USER")
	       expectedPass := os.Getenv("DASH_PASS")
	       if expectedUser == "" { expectedUser = "admin" }
	       if expectedPass == "" { expectedPass = "demo" }
	       if !ok || user != expectedUser || pass != expectedPass {
		       w.Header().Set("WWW-Authenticate", "Basic realm=Restricted")
		       w.WriteHeader(http.StatusUnauthorized)
		       w.Write([]byte("Unauthorized"))
		       return
	       }
	       next(w, r)
       }
}
