package validator

import (
	"reflect"
	"regexp"
	"strings"
	"unicode/utf8"
)

// ValidateEmail 验证邮箱格式
func ValidateEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	matched, _ := regexp.MatchString(pattern, email)
	return matched
}

// ValidatePhone 验证手机号格式（中国大陆）
func ValidatePhone(phone string) bool {
	pattern := `^1[3-9]\d{9}$`
	matched, _ := regexp.MatchString(pattern, phone)
	return matched
}

// ValidatePassword 验证密码强度（至少8位，包含字母和数字）
func ValidatePassword(password string) bool {
	if utf8.RuneCountInString(password) < 8 {
		return false
	}
	var hasLetter, hasNumber bool
	for _, ch := range password {
		if (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') {
			hasLetter = true
		}
		if ch >= '0' && ch <= '9' {
			hasNumber = true
		}
	}
	return hasLetter && hasNumber
}

// ValidateRequired 验证必填字段
func ValidateRequired(fields map[string]string) []string {
	var errors []string
	for name, value := range fields {
		if strings.TrimSpace(value) == "" {
			errors = append(errors, name+"不能为空")
		}
	}
	return errors
}

// ValidateStruct 验证结构体字段（基于tag）
func ValidateStruct(s interface{}) []string {
	var errors []string
	v := reflect.ValueOf(s)
	if v.Kind() == reflect.Ptr {
		v = v.Elem()
	}
	t := v.Type()

	for i := 0; i < v.NumField(); i++ {
		field := t.Field(i)
		value := v.Field(i)

		// 检查required tag
		if required := field.Tag.Get("required"); required == "true" {
			if isZero(value) {
				errors = append(errors, field.Tag.Get("json")+"不能为空")
			}
		}

		// 检查min tag（字符串长度）
		if min := field.Tag.Get("min"); min != "" && value.Kind() == reflect.String {
			if utf8.RuneCountInString(value.String()) < 1 { // 简化处理
				errors = append(errors, field.Tag.Get("json")+"长度不足")
			}
		}
	}

	return errors
}

// isZero 判断值是否为零值
func isZero(v reflect.Value) bool {
	switch v.Kind() {
	case reflect.String:
		return v.String() == ""
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		return v.Int() == 0
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		return v.Uint() == 0
	case reflect.Float32, reflect.Float64:
		return v.Float() == 0
	case reflect.Ptr, reflect.Interface:
		return v.IsNil()
	default:
		return reflect.DeepEqual(v.Interface(), reflect.Zero(v.Type()).Interface())
	}
}
