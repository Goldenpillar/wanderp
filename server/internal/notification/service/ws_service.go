package service

import (
	"github.com/gorilla/websocket"
	"github.com/wanderp/server/internal/notification"
)

// WSService WebSocket服务接口
type WSService interface {
	// HandleConnection 处理WebSocket连接
	HandleConnection(client *notification.Client)
	// SendToUser 发送消息给指定用户
	SendToUser(userID uint, msg *notification.Message) error
	// Broadcast 广播消息
	Broadcast(msg *notification.Message) error
	// SendToTrip 发送消息给行程成员
	SendToTrip(tripID uint, msg *notification.Message) error
	// GetOnlineUsers 获取在线用户列表
	GetOnlineUsers() []uint
}

// wsService WebSocket服务实现
type wsService struct {
	hub      *notification.Hub
	upgrader *websocket.Upgrader
}

// NewWSService 创建WebSocket服务实例
func NewWSService(hub *notification.Hub) WSService {
	return &wsService{
		hub: hub,
		upgrader: &websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
			CheckOrigin: func(r *http.Request) bool {
				return true // 生产环境需要限制来源
			},
		},
	}
}

// HandleConnection 处理WebSocket连接
func (s *wsService) HandleConnection(client *notification.Client) {
	// 注册客户端
	s.hub.Register <- client

	// 启动读写协程
	go s.writePump(client)
	go s.readPump(client)
}

// writePump 写入消息泵
func (s *wsService) writePump(client *notification.Client) {
	defer func() {
		client.Conn.Close()
	}()

	for {
		select {
		case message, ok := <-client.Send:
			if !ok {
				// 通道已关闭
				client.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			// TODO: 写入WebSocket消息
			_ = message
		}
	}
}

// readPump 读取消息泵
func (s *wsService) readPump(client *notification.Client) {
	defer func() {
		s.hub.Unregister <- client
		client.Conn.Close()
	}()

	for {
		_, message, err := client.Conn.ReadMessage()
		if err != nil {
			break
		}

		// TODO: 处理接收到的消息
		_ = message
	}
}

// SendToUser 发送消息给指定用户
func (s *wsService) SendToUser(userID uint, msg *notification.Message) error {
	s.hub.Unicast <- msg
	return nil
}

// Broadcast 广播消息
func (s *wsService) Broadcast(msg *notification.Message) error {
	s.hub.Broadcast <- msg
	return nil
}

// SendToTrip 发送消息给行程成员
func (s *wsService) SendToTrip(tripID uint, msg *notification.Message) error {
	msg.TripID = tripID
	s.hub.GroupCast <- msg
	return nil
}

// GetOnlineUsers 获取在线用户列表
func (s *wsService) GetOnlineUsers() []uint {
	s.hub.mu.RLock()
	defer s.hub.mu.RUnlock()

	users := make([]uint, 0, len(s.hub.clients))
	for id := range s.hub.clients {
		users = append(users, id)
	}
	return users
}
