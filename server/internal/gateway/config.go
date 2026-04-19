package gateway

// GatewayConfig 网关配置
type GatewayConfig struct {
	Port int `mapstructure:"port"`
}

// ServiceRoute 下游服务路由配置
type ServiceRoute struct {
	Name        string `mapstructure:"name"`
	Prefix      string `mapstructure:"prefix"`
	UpstreamURL string `mapstructure:"upstream_url"`
}

// Services 下游服务列表
var Services = []ServiceRoute{
	{
		Name:        "user",
		Prefix:      "/api/v1/user",
		UpstreamURL: "http://localhost:8001",
	},
	{
		Name:        "planner",
		Prefix:      "/api/v1/planner",
		UpstreamURL: "http://localhost:8002",
	},
	{
		Name:        "map",
		Prefix:      "/api/v1/map",
		UpstreamURL: "http://localhost:8003",
	},
	{
		Name:        "notification",
		Prefix:      "/api/v1/notification",
		UpstreamURL: "http://localhost:8004",
	},
}
