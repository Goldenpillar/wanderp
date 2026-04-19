package mqtt

import (
	"fmt"
	"sync"

	pahomqtt "github.com/eclipse/paho.mqtt.golang"
)

var (
	client pahomqtt.Client
	once   sync.Once
)

// InitMQTT 初始化MQTT客户端
func InitMQTT(broker, clientID, username, password string) (pahomqtt.Client, error) {
	var initErr error
	once.Do(func() {
		opts := pahomqtt.NewClientOptions().
			AddBroker(broker).
			SetClientID(clientID).
			SetUsername(username).
			SetPassword(password).
			SetAutoReconnect(true).
			SetCleanSession(true)

		client = pahomqtt.NewClient(opts)
		token := client.Connect()
		token.Wait()
		if token.Error() != nil {
			initErr = fmt.Errorf("MQTT连接失败: %w", token.Error())
			return
		}
	})
	return client, initErr
}

// Publish 发布消息
func Publish(topic string, qos byte, retained bool, payload interface{}) error {
	if client == nil || !client.IsConnected() {
		return fmt.Errorf("MQTT客户端未连接")
	}
	token := client.Publish(topic, qos, retained, payload)
	token.Wait()
	return token.Error()
}

// Subscribe 订阅主题
func Subscribe(topic string, qos byte, callback pahomqtt.MessageHandler) error {
	if client == nil || !client.IsConnected() {
		return fmt.Errorf("MQTT客户端未连接")
	}
	token := client.Subscribe(topic, qos, callback)
	token.Wait()
	return token.Error()
}

// Disconnect 断开MQTT连接
func Disconnect() {
	if client != nil && client.IsConnected() {
		client.Disconnect(1000)
	}
}
