package eventbuffer

import (
	"sync"
	"time"
)

type KubeEvent struct {
	Resource  string      `json:"resource"`
	Type      string      `json:"type"`
	Namespace string      `json:"namespace"`
	Name      string      `json:"name"`
	Object    interface{} `json:"object"`
	Time      time.Time   `json:"time"`
}

type Buffer struct {
	mu     sync.RWMutex
	buf    []KubeEvent
	maxLen int
}

func NewBuffer(maxLen int) *Buffer {
	return &Buffer{buf: make([]KubeEvent, 0, maxLen), maxLen: maxLen}
}

func (b *Buffer) Add(event KubeEvent) {
	b.mu.Lock()
	defer b.mu.Unlock()
	if len(b.buf) >= b.maxLen {
		b.buf = b.buf[1:]
	}
	b.buf = append(b.buf, event)
}

func (b *Buffer) GetAll() []KubeEvent {
	b.mu.RLock()
	defer b.mu.RUnlock()
	return append([]KubeEvent(nil), b.buf...)
}

func (b *Buffer) GetRecent(n int) []KubeEvent {
	b.mu.RLock()
	defer b.mu.RUnlock()
	if n > len(b.buf) {
		n = len(b.buf)
	}
	return append([]KubeEvent(nil), b.buf[len(b.buf)-n:]...)
}
