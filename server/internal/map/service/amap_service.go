package service

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"

	"github.com/wanderp/server/internal/map/model"
)

// AMapService 高德地图API服务接口
type AMapService interface {
	// SearchPOI 搜索兴趣点
	SearchPOI(ctx context.Context, req *model.POISearchRequest) ([]model.POI, error)
	// GetPOIDetail 获取POI详情
	GetPOIDetail(ctx context.Context, poiID string) (*model.POI, error)
	// Geocode 地理编码（地址转坐标）
	Geocode(ctx context.Context, address, city string) (*model.Location, error)
	// ReverseGeocode 逆地理编码（坐标转地址）
	ReverseGeocode(ctx context.Context, lat, lng float64) (*model.Location, error)
	// GetWeather 获取天气信息
	GetWeather(ctx context.Context, city string) (interface{}, error)
}

// aMapService 高德地图API服务实现
type aMapService struct {
	apiKey  string
	baseURL string
	client  *http.Client
}

// NewAMapService 创建高德地图服务实例
func NewAMapService(apiKey, baseURL string) AMapService {
	return &aMapService{
		apiKey:  apiKey,
		baseURL: baseURL,
		client:  &http.Client{Timeout: 10 * time.Second},
	}
}

// SearchPOI 搜索兴趣点
func (s *aMapService) SearchPOI(ctx context.Context, req *model.POISearchRequest) ([]model.POI, error) {
	// TODO: 调用高德地图POI搜索API
	// https://restapi.amap.com/v3/place/text
	params := url.Values{}
	params.Set("key", s.apiKey)
	params.Set("keywords", req.Keyword)
	if req.City != "" {
		params.Set("city", req.City)
	}
	if req.Category != "" {
		params.Set("types", req.Category)
	}
	params.Set("offset", fmt.Sprintf("%d", req.PageSize))
	params.Set("page", fmt.Sprintf("%d", req.Page))
	params.Set("output", "JSON")

	// TODO: 发送HTTP请求并解析响应
	_ = params

	return nil, nil
}

// GetPOIDetail 获取POI详情
func (s *aMapService) GetPOIDetail(ctx context.Context, poiID string) (*model.POI, error) {
	// TODO: 调用高德地图POI详情API
	// https://restapi.amap.com/v3/place/detail
	_ = poiID
	return nil, nil
}

// Geocode 地理编码
func (s *aMapService) Geocode(ctx context.Context, address, city string) (*model.Location, error) {
	// TODO: 调用高德地图地理编码API
	// https://restapi.amap.com/v3/geocode/geo
	_ = address
	_ = city
	return nil, nil
}

// ReverseGeocode 逆地理编码
func (s *aMapService) ReverseGeocode(ctx context.Context, lat, lng float64) (*model.Location, error) {
	// TODO: 调用高德地图逆地理编码API
	// https://restapi.amap.com/v3/geocode/regeo
	_ = lat
	_ = lng
	return nil, nil
}

// GetWeather 获取天气信息
func (s *aMapService) GetWeather(ctx context.Context, city string) (interface{}, error) {
	// TODO: 调用高德地图天气API
	_ = city
	return nil, nil
}

// amapRequest 高德API通用请求方法
func (s *aMapService) amapRequest(ctx context.Context, path string, params url.Values) (json.RawMessage, error) {
	params.Set("key", s.apiKey)
	reqURL := fmt.Sprintf("%s%s?%s", s.baseURL, path, params.Encode())

	req, err := http.NewRequestWithContext(ctx, "GET", reqURL, nil)
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}

	resp, err := s.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("请求失败: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %w", err)
	}

	return json.RawMessage(body), nil
}
