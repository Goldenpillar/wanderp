package model

// RouteStep 路线步骤
type RouteStep struct {
	Instruction string   `json:"instruction" example:"沿长安街向东行驶"`
	Road        string   `json:"road" example:"长安街"`
	Distance    int      `json:"distance" example:"500"`
	Duration    int      `json:"duration" example:"120"`
	Direction   string   `json:"direction" example:"东"`
	Location    Location `json:"location"`
}

// RouteLeg 路线段
type RouteLeg struct {
	Origin      Location    `json:"origin"`
	Destination Location    `json:"destination"`
	Steps       []RouteStep `json:"steps"`
	Distance    int         `json:"distance" example:"5000"`
	Duration    int         `json:"duration" example:"600"`
	Tolls       float64     `json:"tolls" example:"10"`
	TrafficLights int       `json:"traffic_lights" example:"12"`
}

// Route 路线模型
type Route struct {
	Origin      Location    `json:"origin"`
	Destination Location    `json:"destination"`
	Legs        []RouteLeg  `json:"legs"`
	Distance    int         `json:"distance" example:"5000"`
	Duration    int         `json:"duration" example:"600"`
	Polyline    string      `json:"polyline,omitempty"`
	Strategy    string      `json:"strategy" example:"fastest"`
}

// RouteRequest 路线规划请求
type RouteRequest struct {
	Origin      Location `json:"origin" binding:"required"`
	Destination Location `json:"destination" binding:"required"`
	Mode        string   `json:"mode" binding:"required" example:"driving"` // driving/walking/transit/cycling
	Waypoints   []Location `json:"waypoints,omitempty"`
	Strategy    string   `json:"strategy,omitempty" example:"fastest"` // fastest/shortest/most_economic
	AvoidTolls  bool     `json:"avoid_tolls,omitempty"`
	AvoidHighway bool    `json:"avoid_highway,omitempty"`
}

// TrajectoryPoint 轨迹点
type TrajectoryPoint struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Speed     float64 `json:"speed"`
	Direction float64 `json:"direction"`
	Altitude  float64 `json:"altitude"`
	Timestamp int64   `json:"timestamp"`
}

// Trajectory 轨迹模型
type Trajectory struct {
	TripID      uint              `json:"trip_id"`
	UserID      uint              `json:"user_id"`
	Points      []TrajectoryPoint `json:"points"`
	TotalDist   float64           `json:"total_distance"`
	TotalTime   int               `json:"total_time"`
	StartTime   int64             `json:"start_time"`
	EndTime     int64             `json:"end_time"`
}
