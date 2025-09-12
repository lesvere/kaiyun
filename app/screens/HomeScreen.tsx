import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Image, SafeAreaView } from 'react-native';
import { AutoImage } from '../components/AutoImage';
import { Screen } from '../components/Screen';
import { Feather as Icon } from '@expo/vector-icons';

const HomeScreen = () => {
  return (
    <Screen preset="scroll" safeAreaEdges={['top']}>
      <AppBanner />
      <Header />
      <ScrollView style={styles.container}>
        <PromoBanner />
        <Ticker />
        <UserActions />
        <MainContent />
      </ScrollView>
      <BottomNav />
    </Screen>
  );
};

const AppBanner = () => (
  <View style={styles.appBanner}>
    <TouchableOpacity style={styles.appBannerClose}>
      <Icon name="x" size={24} color="#666" />
    </TouchableOpacity>
    <View style={styles.appBannerInfo}>
      <View style={styles.appBannerLogo}>
        <Text style={styles.appBannerLogoText}>K</Text>
      </View>
      <View style={styles.appBannerText}>
        <Text style={styles.appBannerTitle}>开云APP</Text>
        <Text style={styles.appBannerSubtitle}>真人娱乐, 体育投注, 电子游艺等尽在一手掌握</Text>
      </View>
    </View>
    <TouchableOpacity style={styles.appBannerButton}>
      <Text style={styles.appBannerButtonText}>立即下载</Text>
    </TouchableOpacity>
  </View>
);

const Header = () => (
  <View style={styles.header}>
    <View style={styles.headerLogo}>
      <View style={styles.headerLogoIcon}>
        <Text style={styles.headerLogoIconText}>K</Text>
      </View>
      <View style={styles.headerLogoText}>
        <Text style={styles.headerTitle}>开云体育</Text>
        <Text style={styles.headerSubtitle}>kaiyun.com</Text>
      </View>
    </View>
    <View style={styles.headerInfo}>
      <Text style={styles.headerDomain}>永久网址: kaiyun.com</Text>
      <TouchableOpacity>
        <Icon name="search" size={24} color="#666" />
      </TouchableOpacity>
      <TouchableOpacity>
        <Icon name="message-square" size={24} color="#666" />
      </TouchableOpacity>
    </View>
  </View>
);

const PromoBanner = () => (
  <View style={styles.promoBanner}>
    <View style={styles.promoBannerPlayers} />
    <View style={styles.promoBannerContent}>
      <Text style={styles.promoBannerTitle}>助威金球巨星</Text>
      <Text style={styles.promoBannerSubtitle}>投票瓜分百万奖池</Text>
      <Text style={styles.promoBannerDate}>2025年9月6日 - 9月21日</Text>
    </View>
    <View style={styles.promoBannerDots}>
      <View style={[styles.dot, styles.activeDot]} />
      <View style={styles.dot} />
      <View style={styles.dot} />
      <View style={styles.dot} />
    </View>
  </View>
);

const Ticker = () => (
  <View style={styles.ticker}>
    <Icon name="volume-2" size={24} color="#666" />
    <View style={styles.tickerContent}>
      <Text style={styles.tickerText}>
        尊敬的客户: 我司FB体育场馆于
        <Text style={styles.tickerTag}> LIVE 直播中 </Text>
        <Text style={styles.tickerTag}> HOT 热门赛事 </Text>
      </Text>
    </View>
  </View>
);

const UserActions = () => {
  const actions: { name: string; icon: keyof typeof Icon.glyphMap }[] = [
    { name: '存款', icon: 'download' },
    { name: '转账', icon: 'refresh-cw' },
    { name: '取款', icon: 'upload' },
    { name: 'VIP', icon: 'star' },
    { name: '推广', icon: 'users' },
  ];

  return (
    <View style={styles.userActions}>
      <View style={styles.userInfo}>
        <Text style={styles.userInfoTitle}>您还未登录</Text>
        <Text style={styles.userInfoSubtitle}>登录/注册后查看</Text>
      </View>
      <View style={styles.actionButtons}>
        {actions.map(action => (
          <TouchableOpacity key={action.name} style={styles.actionButton}>
            <Icon name={action.icon} size={24} color="#666" />
            <Text style={styles.actionButtonText}>{action.name}</Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );
};

const MainContent = () => (
  <View style={styles.mainContent}>
    <SideNav />
    <ContentCards />
  </View>
);

const SideNav = () => {
  const [activeItem, setActiveItem] = useState('体育');
  const navItems: { name: string; icon: keyof typeof Icon.glyphMap }[] = [
    { name: '体育', icon: 'activity' },
    { name: '真人', icon: 'grid' },
    { name: '棋牌', icon: 'bell' },
    { name: '电竞', icon: 'target' },
    { name: '彩票', icon: 'help-circle' },
    { name: '电子', icon: 'zap' },
    { name: '娱乐', icon: 'star' },
  ];

  return (
    <View style={styles.sideNav}>
      {navItems.map(item => (
        <TouchableOpacity
          key={item.name}
          style={[styles.sideNavItem, activeItem === item.name && styles.sideNavItemActive]}
          onPress={() => setActiveItem(item.name)}
        >
          <Icon name={item.icon} size={24} color={activeItem === item.name ? '#fff' : '#666'} />
          <Text style={[styles.sideNavText, activeItem === item.name && styles.sideNavTextActive]}>
            {item.name}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );
};

const ContentCards = () => {
  const cards = [
    { name: '开云体育', sub: 'KAIYUN SPORTS', games: 2714, tag1: '高达1.18%', tag2: '无限返水', hasBadge: true },
    { name: '熊猫体育', sub: 'PANDA SPORTS', games: 2347, tag1: '高达1.18%', tag2: '无限返水', hasBadge: false },
    { name: 'IM体育', sub: 'IM SPORTS', games: 2046, tag1: '高达1.18%', tag2: '无限返水', hasBadge: false },
  ];

  return (
    <View style={styles.contentCards}>
      {cards.map(card => (
        <View key={card.name} style={styles.contentCard}>
          {card.hasBadge && (
            <View style={styles.cardBadge}>
              <Text style={styles.cardBadgeText}>✓ 官方认证</Text>
            </View>
          )}
          <View style={styles.contentCardInfo}>
            <Text style={styles.contentCardTitle}>{card.name}</Text>
            <Text style={styles.contentCardSubtitle}>{card.sub}</Text>
            <View style={styles.contentCardStats}>
              <Text style={styles.contentCardStatsNumber}>{card.games}</Text>
              <Text style={styles.contentCardStatsText}>场</Text>
            </View>
            <View style={styles.contentCardTags}>
              <View style={styles.cardTag}>
                <Text style={styles.cardTagText}>{card.tag1}</Text>
              </View>
              <View style={[styles.cardTag, styles.cardTagBlue]}>
                <Text style={styles.cardTagText}>{card.tag2}</Text>
              </View>
            </View>
          </View>
          <View style={styles.contentCardPlayers}>
            <View style={[styles.playerPlaceholder, styles.player1]} />
            <View style={[styles.playerPlaceholder, styles.player2]} />
            <View style={[styles.playerPlaceholder, styles.player3]} />
          </View>
        </View>
      ))}
    </View>
  );
};

const BottomNav = () => {
  const [activeItem, setActiveItem] = useState('首页');
  const navItems: { name: string; icon: keyof typeof Icon.glyphMap }[] = [
    { name: '首页', icon: 'home' },
    { name: '优惠', icon: 'gift' },
    { name: '客服', icon: 'headphones' },
    { name: '赞助', icon: 'heart' },
    { name: '我的', icon: 'user' },
  ];

  return (
    <View style={styles.bottomNav}>
      {navItems.map(item => (
        <TouchableOpacity
          key={item.name}
          style={[styles.bottomNavItem, activeItem === item.name && styles.bottomNavItemActive]}
          onPress={() => setActiveItem(item.name)}
        >
          <Icon name={item.icon} size={24} color={activeItem === item.name ? '#0066ff' : '#666'} />
          <Text style={[styles.bottomNavText, activeItem === item.name && styles.bottomNavTextActive]}>
            {item.name}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  appBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  appBannerClose: {
    padding: 8,
  },
  appBannerInfo: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: 12,
  },
  appBannerLogo: {
    width: 40,
    height: 40,
    borderRadius: 8,
    backgroundColor: '#0066ff',
    justifyContent: 'center',
    alignItems: 'center',
  },
  appBannerLogoText: {
    color: '#fff',
    fontSize: 24,
    fontWeight: 'bold',
  },
  appBannerText: {
    marginLeft: 12,
  },
  appBannerTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  appBannerSubtitle: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  appBannerButton: {
    backgroundColor: '#0066ff',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 20,
  },
  appBannerButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '500',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
    backgroundColor: '#fff',
  },
  headerLogo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerLogoIcon: {
    width: 36,
    height: 36,
    borderRadius: 8,
    backgroundColor: '#0066ff',
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerLogoIconText: {
    color: '#fff',
    fontSize: 20,
    fontWeight: 'bold',
  },
  headerLogoText: {
    marginLeft: 8,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  headerSubtitle: {
    fontSize: 12,
    color: '#666',
  },
  headerInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
  },
  headerDomain: {
    fontSize: 12,
    color: '#666',
  },
  promoBanner: {
    height: 180,
    backgroundColor: '#0066ff',
    borderRadius: 12,
    margin: 16,
    padding: 16,
    position: 'relative',
  },
  promoBannerPlayers: {
    position: 'absolute',
    right: 0,
    bottom: 0,
    width: '50%',
    height: '100%',
  },
  promoBannerContent: {
    flex: 1,
    justifyContent: 'center',
  },
  promoBannerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  promoBannerSubtitle: {
    fontSize: 20,
    fontWeight: '500',
    color: '#fff',
    marginTop: 8,
  },
  promoBannerDate: {
    fontSize: 14,
    color: '#fff',
    marginTop: 10,
  },
  promoBannerDots: {
    flexDirection: 'row',
    position: 'absolute',
    bottom: 16,
    left: 16,
    gap: 8,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: 'rgba(255,255,255,0.5)',
  },
  activeDot: {
    backgroundColor: '#fff',
  },
  ticker: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    backgroundColor: '#fff',
    marginHorizontal: 16,
    borderRadius: 8,
  },
  tickerContent: {
    flex: 1,
    marginLeft: 12,
  },
  tickerText: {
    fontSize: 14,
    color: '#333',
  },
  tickerTag: {
    color: '#0066ff',
    fontWeight: '500',
  },
  userActions: {
    backgroundColor: '#fff',
    margin: 16,
    borderRadius: 12,
    padding: 16,
  },
  userInfo: {
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
    paddingBottom: 16,
  },
  userInfoTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
  },
  userInfoSubtitle: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  actionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 16,
  },
  actionButton: {
    alignItems: 'center',
  },
  actionButtonText: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  mainContent: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    marginHorizontal: 16,
    borderRadius: 12,
    padding: 16,
  },
  sideNav: {
    width: 80,
    borderRightWidth: 1,
    borderRightColor: '#eee',
  },
  sideNavItem: {
    alignItems: 'center',
    padding: 12,
  },
  sideNavItemActive: {
    backgroundColor: '#0066ff',
    borderRadius: 8,
  },
  sideNavText: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  sideNavTextActive: {
    color: '#fff',
  },
  contentCards: {
    flex: 1,
    marginLeft: 16,
  },
  contentCard: {
    backgroundColor: '#f8f8f8',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
  },
  cardBadge: {
    position: 'absolute',
    top: 12,
    right: 12,
    backgroundColor: '#0066ff',
    paddingVertical: 4,
    paddingHorizontal: 8,
    borderRadius: 12,
  },
  cardBadgeText: {
    color: '#fff',
    fontSize: 12,
  },
  contentCardInfo: {
    flex: 1,
  },
  contentCardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  contentCardSubtitle: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  contentCardStats: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginTop: 8,
  },
  contentCardStatsNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#0066ff',
  },
  contentCardStatsText: {
    fontSize: 14,
    color: '#666',
    marginLeft: 4,
  },
  contentCardTags: {
    flexDirection: 'row',
    marginTop: 12,
    gap: 8,
  },
  cardTag: {
    backgroundColor: '#fff',
    paddingVertical: 4,
    paddingHorizontal: 8,
    borderRadius: 4,
  },
  cardTagBlue: {
    backgroundColor: '#e6f0ff',
  },
  cardTagText: {
    fontSize: 12,
    color: '#0066ff',
  },
  contentCardPlayers: {
    flexDirection: 'row',
    marginTop: 16,
    gap: 8,
  },
  playerPlaceholder: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#ddd',
  },
  player1: {
    backgroundColor: '#e6f0ff',
  },
  player2: {
    backgroundColor: '#f0f0f0',
  },
  player3: {
    backgroundColor: '#f5f5f5',
  },
  bottomNav: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingVertical: 8,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  bottomNavItem: {
    alignItems: 'center',
    padding: 8,
  },
  bottomNavItemActive: {
    backgroundColor: 'transparent',
  },
  bottomNavText: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  bottomNavTextActive: {
    color: '#0066ff',
  },
});

export default HomeScreen;
