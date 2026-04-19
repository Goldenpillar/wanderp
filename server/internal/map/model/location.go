package model

// Location 位置模型
type Location struct {
	Latitude  float64 `json:"latitude" example:"39.9042"`
	Longitude float64 `json:"longitude" example:"116.4074"`
	Address   string  `json:"address" example:"北京市东城区天安门"`
	City      string  `json:"city" example:"北京"`
	Province  string  `json:"province" example:"北京市"`
}

// POI 兴趣点模型
type POI struct {
	ID        string   `json:"id" example:"B000A83M61"`
	Name      string   `json:"name" example:"故宫博物院"`
	Type      string   `json:"type" example:"风景名胜"`
	Address   string   `json:"address" example:"北京市东城区景山前街4号"`
	Location  Location `json:"location"`
	Tel       string   `json:"tel,omitempty" example:"010-85007114"`
	Rating    float64  `json:"rating" example:"4.8"`
	Cost      float64  `json:"cost,omitempty" example:"60"`
	PhotoURL  string   `json:"photo_url,omitempty"`
	OpenTime  string   `json:"open_time,omitempty" example:"08:30-17:00"`
	Category  string   `json:"category" example:"sightseeing"`
	Tags      []string `json:"tags,omitempty"`
	Distance  float64  `json:"distance,omitempty" example:"1500"`
}

// POISearchRequest POI搜索请求
type POISearchRequest struct {
	Keyword  string   `json:"keyword" form:"keyword" example:"美食"`
	City     string   `json:"city" form:"city" example:"北京"`
	Category string   `json:"category" form:"category" example:"餐饮服务"`
	Latitude float64  `json:"latitude" form:"latitude" example:"39.9042"`
	Longitude float64 `json:"longitude" form:"longitude" example:"116.4074"`
	Radius   int      `json:"radius" form:"radius" example:"3000"`
	Types    []string `json:"types" form:"types"`
	SortBy   string   `json:"sort_by" form:"sort_by" example:"distance"`
	Page     int      `json:"page" form:"page" example:"1"`
	PageSize int      `json:"page_size" form:"page_size" example:"20"`
}
