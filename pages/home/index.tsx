import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';

const App = () => {
    return (
        <div className="app-container">
            <AppBanner />
            <Header />
            <main>
                <PromoBanner />
                <Ticker />
                <UserActions />
                <MainContent />
            </main>
            <BottomNav />
        </div>
    );
};

const AppBanner = () => (
    <div className="app-banner">
        <button className="app-banner-close" aria-label="Close">&times;</button>
        <div className="app-banner-info">
            <div className="app-banner-logo">K</div>
            <div className="app-banner-text">
                <h4>开云APP</h4>
                <p>真人娱乐, 体育投注, 电子游艺等尽在一手掌握</p>
            </div>
        </div>
        <button className="app-banner-button">立即下载</button>
    </div>
);

const Header = () => (
    <header className="header">
        <div className="header-logo">
            <div className="header-logo-icon">K</div>
            <div className="header-logo-text">
                <h3>开云体育</h3>
                <span>kaiyun.com</span>
            </div>
        </div>
        <div className="header-info">
            <span>永久网址: kaiyun.com</span>
            <SearchIcon />
            <ChatIcon />
        </div>
    </header>
);

const PromoBanner = () => (
    <div className="promo-banner">
        <div className="promo-banner-players"></div>
        <div className="promo-banner-content">
            <h2>助威金球巨星</h2>
            <p style={{fontSize: '20px', fontWeight: 500}}>投票瓜分百万奖池</p>
            <p style={{marginTop: '10px'}}>2025年9月6日 - 9月21日</p>
        </div>
        <div className="promo-banner-dots">
            <span className="active"></span>
            <span></span>
            <span></span>
            <span></span>
        </div>
    </div>
);

const Ticker = () => (
     <div className="ticker">
        <SpeakerIcon />
        <div className="ticker-content">
            <p>尊敬的客户: 我司FB体育场馆于<span className="ticker-tag">LIVE 直播中</span><span className="ticker-tag">HOT 热门赛事</span></p>
        </div>
    </div>
);

const UserActions = () => {
    const actions = [
        { name: '存款', icon: <DepositIcon /> },
        { name: '转账', icon: <TransferIcon /> },
        { name: '取款', icon: <WithdrawIcon /> },
        { name: 'VIP', icon: <VipIcon /> },
        { name: '推广', icon: <PromoteIcon /> },
    ];
    return (
        <div className="user-actions">
            <div className="user-info">
                <p>您还未登录</p>
                <span>登录/注册后查看</span>
            </div>
            <div className="action-buttons">
                {actions.map(action => (
                    <div className="action-button" key={action.name}>
                        <div className="action-button-icon">{action.icon}</div>
                        <span>{action.name}</span>
                    </div>
                ))}
            </div>
        </div>
    );
};

const MainContent = () => (
    <div className="main-content">
        <SideNav />
        <ContentCards />
    </div>
);

const SideNav = () => {
    const [activeItem, setActiveItem] = useState('体育');
    const navItems = [
        { name: '体育', icon: <SportsIcon /> },
        { name: '真人', icon: <LiveIcon /> },
        { name: '棋牌', icon: <ChessIcon /> },
        { name: '电竞', icon: <EsportsIcon /> },
        { name: '彩票', icon: <LotteryIcon /> },
        { name: '电子', icon: <SlotsIcon /> },
        { name: '娱乐', icon: <EntertainmentIcon /> },
    ];
    return (
        <nav className="side-nav">
            {navItems.map(item => (
                <div 
                    key={item.name} 
                    className={`side-nav-item ${activeItem === item.name ? 'active' : ''}`}
                    onClick={() => setActiveItem(item.name)}
                >
                    <div className="side-nav-icon">{item.icon}</div>
                    <span>{item.name}</span>
                </div>
            ))}
        </nav>
    );
};

const ContentCards = () => {
    const cards = [
        { name: '开云体育', sub: 'KAIYUN SPORTS', games: 2714, tag1: '高达1.18%', tag2: '无限返水', hasBadge: true },
        { name: '熊猫体育', sub: 'PANDA SPORTS', games: 2347, tag1: '高达1.18%', tag2: '无限返水', hasBadge: false },
        { name: 'IM体育', sub: 'IM SPORTS', games: 2046, tag1: '高达1.18%', tag2: '无限返水', hasBadge: false },
    ];
    return (
        <div className="content-cards">
            {cards.map(card => (
                 <div className="content-card" key={card.name}>
                    {card.hasBadge && <div className="card-badge">✓ 官方认证</div>}
                    <div className="content-card-info">
                        <h4>{card.name}</h4>
                        <p>{card.sub}</p>
                        <div className="content-card-stats">{card.games}<span>场</span></div>
                        <div className="content-card-tags">
                            <span className="card-tag">{card.tag1}</span>
                            <span className="card-tag card-tag-blue">{card.tag2}</span>
                        </div>
                    </div>
                    <div className="content-card-players">
                        <div className="player-placeholder player-1"></div>
                        <div className="player-placeholder player-2"></div>
                        <div className="player-placeholder player-3"></div>
                    </div>
                </div>
            ))}
        </div>
    );
};

const BottomNav = () => {
    const [activeItem, setActiveItem] = useState('首页');
    const navItems = [
        { name: '首页', icon: <HomeIcon /> },
        { name: '优惠', icon: <GiftIcon /> },
        { name: '客服', icon: <HeadphonesIcon /> },
        { name: '赞助', icon: <SponsorIcon /> },
        { name: '我的', icon: <UserIcon /> },
    ];
    return (
        <footer className="bottom-nav">
            {navItems.map(item => (
                <div 
                    key={item.name} 
                    className={`bottom-nav-item ${activeItem === item.name ? 'active' : ''}`}
                    onClick={() => setActiveItem(item.name)}
                >
                    {item.icon}
                    <span>{item.name}</span>
                </div>
            ))}
        </footer>
    );
};

// SVG Icons
const SearchIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>);
const ChatIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>);
const SpeakerIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon><path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"></path></svg>);

const DepositIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>);
const TransferIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>);
const WithdrawIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M21 12V7H3v5"></path><path d="M12 12v6"></path><path d="M15 15l-3 3-3-3"></path><path d="M3 7V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v2"></path></svg>);
const VipIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>);
const PromoteIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>);

const SportsIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-12h2v4h-2zm0 6h2v2h-2z"></path></svg>);
const LiveIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>);
const ChessIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>);
const EsportsIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"></path></svg>);
const LotteryIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>);
const SlotsIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg>);
const EntertainmentIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>);

const HomeIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>);
const GiftIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><polyline points="20 12 20 22 4 22 4 12"></polyline><rect x="2" y="7" width="20" height="5"></rect><line x1="12" y1="22" x2="12" y2="7"></line><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"></path><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"></path></svg>);
const HeadphonesIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M21 12v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-3"></path><path d="M3 12A9 9 0 0 1 12 3v0a9 9 0 0 1 9 9"></path></svg>);
const SponsorIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"></path></svg>);
const UserIcon = () => (<svg xmlns="http://www.w3.org/2000/svg" className="icon" viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>);

const container = document.getElementById('root');
const root = createRoot(container!);
root.render(<App />);
