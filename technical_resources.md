# 开云体育网站技术资源清单

## 1. 截图文档

### 1.1 主要页面截图
1. **网站初始页面** - `website_initial_page.png`
   - 用户中心页面，显示VIP服务、金融操作、账户管理等功能
   - 底部导航栏完整展示

2. **登录页面** - `login_page.png`
   - 展示开云体育合作伙伴信息
   - 显示与皇马、国米、AC米兰的合作关系

3. **存款页面** - `deposit_page.png`
   - 点击存款按钮后的页面状态
   - 同样显示合作伙伴信息

4. **点击后页面** - `after_click_page.png`
   - 元素交互后的页面状态

5. **优惠页面** - `promotions_page.png`
   - 优惠活动列表页面

6. **最终主页面** - `main_page_final.png`
   - 回到主页后的最终状态

## 2. HTML结构分析

### 2.1 页面结构特征
```html
<!DOCTYPE html>
<html>
<head>
  <meta charSet="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no,viewport-fit=cover">
  <meta http-equiv="Content-Language" content="zh-CN">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="referrer" content="origin">
  <link rel="manifest" href="/manifest.json">
  <meta name="screen-orientation" content="portrait">
  <title>开云体育</title>
</head>
```

### 2.2 Next.js配置信息
- **Build ID**: 628a2ab2a4172317b4cce5268c07f85d
- **页面路由**: /mine
- **自定义服务器**: 启用
- **SSG支持**: 启用

## 3. CSS样式资源

### 3.1 样式文件列表
```
/_next/static/css/3bc273d6bf252bb6.css - 核心样式
/_next/static/css/967ecda724b46595.css - 组件样式
/_next/static/css/c83b3f6854f265e5.css - 布局样式
/_next/static/css/d7ada3c62811a479.css - 主题样式
/_next/static/css/ed304aac6bd9f9ad.css - 动画样式
/_next/static/css/f642b765ecabe3bb.css - 响应式样式
```

### 3.2 字体资源
```
/font/fonttext/Akrobat-ExtraBold.otf - 主要显示字体
```

### 3.3 图标资源
```
/_next/static/chunks/images/ic_launcher_fullsite-c8b48c9768c3c3655a309c3b15258d8c.png - 应用图标
```

## 4. JavaScript资源

### 4.1 核心脚本
```javascript
// 主要JavaScript文件
/_next/static/628a2ab2a4172317b4cce5268c07f85d/_buildManifest.js
/_next/static/628a2ab2a4172317b4cce5268c07f85d/_middlewareManifest.js
/_next/static/628a2ab2a4172317b4cce5268c07f85d/_ssgManifest.js

// 应用主文件
/_next/static/chunks/main-050083db0698b8a2.js
/_next/static/chunks/pages/_app-79f3db4e709298a7.js
/_next/static/chunks/pages/mine-82cba9539bf570aa.js

// 功能模块
/_next/static/chunks/2608-9258f08aac185ff0.js
/_next/static/chunks/2639-38cd32979d809a06.js
/_next/static/chunks/3192-d7bf5f73dfe53508.js
/_next/static/chunks/4219-a52eb5b0eb8da4c4.js
/_next/static/chunks/5296-0ded22aa271a6264.js
/_next/static/chunks/7283-7f3d1d95ccf22c28.js
/_next/static/chunks/830-4524f74a104d8525.js
/_next/static/chunks/8651-07c3eef7e958996a.js
/_next/static/chunks/8716-231e9fde4e18afa3.js
/_next/static/chunks/9221-08d0586e82bca4e0.js
/_next/static/chunks/9788-583da763fd3dfd83.js

// 兼容性支持
/_next/static/chunks/polyfills-5cd94c89d3acac5f.js
/_next/static/chunks/webpack-53943292ac85f3e3.js

// 自定义脚本
/js/theme.js
```

### 4.2 第三方服务
```javascript
// Polyfill服务
/v3/polyfill.min.js?flags=gated&features=default%2Ces2015%2Ces2016%2Ces2017%2Ces2018%2Ces2019%2Ces5%2Ces6%2Ces7%2Csmoothscroll%2CResizeObserver%2CAbortController

// 代理服务脚本
/rammerhead.js
/task.js
```

## 5. 图片资源CDN

### 5.1 主要图片资源
```
CDN域名: pos3img.uoenuvy.com

活动图片:
- d143ssuriolb597cptc0_573670.jpg (新手任务活动)
- d143stmriolb597cpteg_961343.png (新手任务活动 - 深色版)
- d143t1inghtku84ir530_500663.jpg (新手任务活动 - 小图)
- d143t2ekegiav47v9090_471869.png (新手任务活动 - 小图深色版)
- d2s1gmjo0aqjjk1n0bk0_778899.jpg (VIP活动)
- d2s1gneriolb5905s1jg_942158.png (VIP活动 - 深色版)
```

## 6. 服务器响应头分析

### 6.1 HTTP响应头
```http
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Fri, 05 Sep 2025 04:09:08 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 21449
Connection: keep-alive
Vary: Accept-Encoding, Accept-Encoding, Accept-Encoding
ETag: "53c9-CJeHGAxLT4LIZ4OnEcoB+JJIbwQ"
Cache-Control: no-cache
Access-Control-Allow-Credentials: true
Expires: Thu, 01 Jan 1970 00:00:01 GMT
C-Type: df
RID: 563cf40fb4a714eab0cab7d2717f0421
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Disposition: attachment;
Referrer-Policy: no-referrer-when-downgrade
```

### 6.2 安全特性
- **HSTS启用**: 强制HTTPS访问，有效期1年
- **CORS配置**: 允许跨域请求带凭据
- **缓存策略**: 禁用缓存确保实时数据
- **内容类型**: 明确指定UTF-8编码

## 7. 移动端适配

### 7.1 视口配置
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no,viewport-fit=cover">
```
- 禁用缩放功能
- 适配全屏显示
- 固定视口大小

### 7.2 移动应用支持
```html
<meta name="screen-orientation" content="portrait">
<meta name="apple-mobile-web-app-title" content="开云-网页版">
<link rel="apple-touch-icon" href="/_next/static/chunks/images/ic_launcher_fullsite-c8b48c9768c3c3655a309c3b15258d8c.png">
<link rel="manifest" href="/manifest.json">
```

## 8. 错误日志分析

### 8.1 控制台错误
```javascript
Error #1: Uncaught TypeError: n.addChangeEventListener is not a function
Location: rammerhead.js:3:5371
Cause: 代理服务脚本错误

Error #2: ServiceWorker registration failed
Cause: Service Worker脚本评估失败
```

### 8.2 错误影响评估
- 代理服务可能影响某些功能的正常使用
- Service Worker失败可能影响离线缓存功能
- 不影响主要业务功能的正常运行

## 9. API接口推断

### 9.1 基于URL结构的API端点
```
认证相关:
- /api/auth/* (推断)
- /login (推断)
- /register (推断)

用户相关:
- /mine/* (确认存在)
  - /mine/rebate (实时返水)
  - /mine/cards (账户管理)
  - /mine/feedback (意见反馈)
  - /mine/helpCenter (帮助中心)
  - /mine/agentPage (代理页面)

记录相关:
- /record/* (确认存在)
  - /record/transaciton (交易记录)
  - /record/bet (投注记录)

活动相关:
- /activity/* (确认存在)
  - /activity/list (优惠活动列表)
  - /activity/friendInvitation (邀请活动)

客服相关:
- /customer/main (客服主页)

赞助相关:
- /sponsor (赞助页面)
```

## 10. 技术栈总结

### 10.1 前端技术
- **框架**: Next.js (React-based)
- **语言**: JavaScript/TypeScript
- **样式**: CSS Modules
- **构建工具**: Webpack
- **包管理**: 可能使用npm/yarn

### 10.2 基础设施
- **Web服务器**: Nginx 1.22.1
- **代理服务**: Rammerhead
- **CDN**: 自建图片CDN (pos3img.uoenuvy.com)
- **安全**: HTTPS + HSTS + CORS

### 10.3 特殊服务
- **Service Worker**: 用于离线支持和缓存
- **PWA支持**: 支持添加到主屏幕
- **多语言**: 主要支持中文简体
- **响应式设计**: 移动端优先