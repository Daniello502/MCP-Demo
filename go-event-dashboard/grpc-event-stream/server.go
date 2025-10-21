package main

import (
	"context"
	"log"
	"net"
	"os"

	"google.golang.org/grpc"
	"go-event-dashboard/internal/eventbuffer"
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "go-event-dashboard/grpc-event-stream"
)

type server struct {
	pb.UnimplementedEventStreamServer
	buf *eventbuffer.Buffer
}

func (s *server) GetRecentEvents(ctx context.Context, req *pb.GetRecentEventsRequest) (*pb.GetRecentEventsResponse, error) {
	events := s.buf.GetRecent(int(req.Limit))
	resp := &pb.GetRecentEventsResponse{}
	for _, e := range events {
		resp.Events = append(resp.Events, &pb.KubeEvent{
			Resource:  e.Resource,
			Type:      e.Type,
			Namespace: e.Namespace,
			Name:      e.Name,
			Time:      timestamppb.New(e.Time),
		})
	}
	return resp, nil
}

func (s *server) StreamEvents(req *pb.StreamEventsRequest, stream pb.EventStream_StreamEventsServer) error {
	lastIdx := 0
	for {
		events := s.buf.GetAll()
		if lastIdx < len(events) {
			for _, e := range events[lastIdx:] {
				if (req.Resource == "" || e.Resource == req.Resource) && (req.Namespace == "" || e.Namespace == req.Namespace) {
					stream.Send(&pb.KubeEvent{
						Resource:  e.Resource,
						Type:      e.Type,
						Namespace: e.Namespace,
						Name:      e.Name,
						Time:      timestamppb.New(e.Time),
					})
				}
			}
			lastIdx = len(events)
		}
		// Simple polling, can be replaced with channels for efficiency
		select {
		case <-stream.Context().Done():
			return nil
		case <-context.Background().Done():
			return nil
		default:
		}
	}
}

func main() {
	buf := eventbuffer.NewBuffer(100)
	grpcServer := grpc.NewServer()
	pb.RegisterEventStreamServer(grpcServer, &server{buf: buf})
	port := os.Getenv("GRPC_PORT")
	if port == "" {
		port = "50051"
	}
	lis, err := net.Listen("tcp", ":"+port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	log.Printf("gRPC server listening on :%s", port)
	grpcServer.Serve(lis)
}
