package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"github.com/wanderp/server/internal/notification"
	"github.com/wanderp/server/internal/pkg/response"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // 生产环境需要限制来源
	},
}

// WebSocketHandler WebSocket处理器
type WebSocketHandler struct {
	hub *notification.Hub
}

// NewWebSocketHandler 创建WebSocket处理器
func NewWebSocketHandler(hub *notification.Hub) *WebSocketHandler {
	return &WebSocketHandler{hub: hub}
}

// HandleWebSocket 处理WebSocket连接
// @Summary WebSocket连接
// @Description 建立WebSocket连接进行实时通信
// @Tags WebSocket
// @Produce json
// @Success 101 {string} string "切换协议到WebSocket"
// @Router /ws [get]
func (h *WebSocketHandler) HandleWebSocket(c *gin.Context) {
	// 升级HTTP连接为WebSocket
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		response.InternalServerError(c, "WebSocket连接升级失败")
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		conn.Close()
		return
	}

	username, _ := c.Get("username")

	// 创建客户端
	client := &notification.Client{
		ID:       userID.(uint),
		Username: username.(string),
		Conn:     conn,
		Send:     make(chan []byte, 256),
		Hub:      h.hub,
	}

	// 注册客户端
	h.hub.Register <- client

	// 启动读写协程
	go h.writePump(client)
	go h.readPump(client)
}

// writePump 写入消息泵
func (h *WebSocketHandler) writePump(client *notification.Client) {
	defer func() {
		client.Conn.Close()
	}()

	for {
		message, ok := <-client.Send
		if !ok {
			client.Conn.WriteMessage(websocket.CloseMessage, []byte{})
			return
		}

		if err := client.Conn.WriteMessage(websocket.TextMessage, message); err != nil {
			break
		}
	}
}

// readPump 读取消息泵
func (h *WebSocketHandler) readPump(client *notification.Client) {
	defer func() {
		h.hub.Unregister <- client
		client.Conn.Close()
	}()

	for {
		_, _, err := client.Conn.ReadMessage()
		if err != nil {
			break
		}
		// TODO: 处理接收到的消息
	}
}

// GetOnlineCount 获取在线人数
// @Summary 获取在线人数
// @Description 获取当前WebSocket在线用户数
// @Tags WebSocket
// @Produce json
// @Success 200 {object} response.Response
// @Router /ws/online [get]
func (h *WebSocketHandler) GetOnlineCount(c *gin.Context) {
	count := h.hub.GetOnlineCount()
	response.Success(c, gin.H{"online_count": count})
}

// RegisterWebSocketRoutes 注册WebSocket路由
func RegisterWebSocketRoutes(r *gin.Engine, hub *notification.Hub) {
	h := NewWebSocketHandler(hub)
	ws := r.Group("/ws")
	{
		ws.GET("", h.HandleWebSocket)
		ws.GET("/online", h.GetOnlineCount)
	}
}
