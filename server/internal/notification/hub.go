package notification

import (
	"sync"
	"time"

	"github.com/gorilla/websocket"
	"go.uber.org/zap"
)

// Client WebSocket客户端
type Client struct {
	ID       uint                   // 用户ID
	Username string                 // 用户名
	Conn     *websocket.Conn        // WebSocket连接
	Send     chan []byte             // 发送消息通道
	Hub      *Hub                   // 所属Hub
}

// Message WebSocket消息
type Message struct {
	Type      string      `json:"type"`       // 消息类型
	Content   interface{} `json:"content"`    // 消息内容
	Timestamp int64       `json:"timestamp"`  // 时间戳
	From      uint        `json:"from"`       // 发送者ID
	To        uint        `json:"to"`         // 接收者ID
	TripID    uint        `json:"trip_id"`    // 关联行程ID
}

// Hub WebSocket连接管理中心
type Hub struct {
	// 已注册的客户端
	clients map[uint]*Client

	// 注册请求
	Register chan *Client

	// 注销请求
	Unregister chan *Client

	// 广播消息
	Broadcast chan *Message

	// 指定用户消息
	Unicast chan *Message

	// 行程组消息
	GroupCast chan *Message

	// 行程成员映射
	TripMembers map[uint][]uint // tripID -> []userID

	mu sync.RWMutex

	log *zap.Logger
}

// NewHub 创建WebSocket Hub
func NewHub(log *zap.Logger) *Hub {
	return &Hub{
		clients:     make(map[uint]*Client),
		Register:    make(chan *Client),
		Unregister:  make(chan *Client),
		Broadcast:   make(chan *Message, 256),
		Unicast:     make(chan *Message, 256),
		GroupCast:   make(chan *Message, 256),
		TripMembers: make(map[uint][]uint),
		log:         log,
	}
}

// Run 启动Hub事件循环
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.Register:
			h.mu.Lock()
			h.clients[client.ID] = client
			h.mu.Unlock()
			h.log.Info("WebSocket客户端已连接", zap.Uint("user_id", client.ID))

		case client := <-h.Unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.ID]; ok {
				delete(h.clients, client.ID)
				close(client.Send)
			}
			h.mu.Unlock()
			h.log.Info("WebSocket客户端已断开", zap.Uint("user_id", client.ID))

		case message := <-h.Broadcast:
			h.mu.RLock()
			for _, client := range h.clients {
				select {
				case client.Send <- h.serializeMessage(message):
				default:
					// 发送通道已满，关闭连接
					close(client.Send)
					delete(h.clients, client.ID)
				}
			}
			h.mu.RUnlock()

		case message := <-h.Unicast:
			h.mu.RLock()
			if client, ok := h.clients[message.To]; ok {
				select {
				case client.Send <- h.serializeMessage(message):
				default:
					close(client.Send)
					delete(h.clients, client.ID)
				}
			}
			h.mu.RUnlock()

		case message := <-h.GroupCast:
			h.mu.RLock()
			if members, ok := h.TripMembers[message.TripID]; ok {
				for _, userID := range members {
					if client, ok := h.clients[userID]; ok {
						select {
						case client.Send <- h.serializeMessage(message):
						default:
							close(client.Send)
							delete(h.clients, client.ID)
						}
					}
				}
			}
			h.mu.RUnlock()
		}
	}
}

// RegisterTripMembers 注册行程成员
func (h *Hub) RegisterTripMembers(tripID uint, userIDs []uint) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.TripMembers[tripID] = userIDs
}

// RemoveTripMember 从行程中移除成员
func (h *Hub) RemoveTripMember(tripID, userID uint) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if members, ok := h.TripMembers[tripID]; ok {
		for i, id := range members {
			if id == userID {
				h.TripMembers[tripID] = append(members[:i], members[i+1:]...)
				break
			}
		}
	}
}

// GetOnlineCount 获取在线用户数
func (h *Hub) GetOnlineCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// IsOnline 检查用户是否在线
func (h *Hub) IsOnline(userID uint) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	_, ok := h.clients[userID]
	return ok
}

// serializeMessage 序列化消息
func (h *Hub) serializeMessage(msg *Message) []byte {
	// TODO: 使用JSON序列化
	msg.Timestamp = time.Now().Unix()
	return []byte{}
}
