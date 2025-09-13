import React from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import { Screen } from '../components/Screen';
import { AppBanner } from '../components/AppBanner';
import { Header } from '../components/Header';
import { PromoBanner } from '../components/PromoBanner';
import { Ticker } from '../components/Ticker';
import { UserActions } from '../components/UserActions';
import { MainContent } from '../components/MainContent';
import { BottomNav } from '../components/BottomNav';
import { colors } from '../theme';

const HomeScreen = () => {
  return (
    <View style={styles.fullScreen}>
      <Screen preset="fixed" safeAreaEdges={['top']}>
        <AppBanner />
        <Header />
        <ScrollView style={styles.container}>
          <PromoBanner />
          <Ticker />
          <UserActions />
          <MainContent />
        </ScrollView>
      </Screen>
      <BottomNav />
    </View>
  );
};

const styles = StyleSheet.create({
  fullScreen: {
    flex: 1,
    backgroundColor: colors.palette.kaiyun_white,
  },
  container: {
    flex: 1,
    backgroundColor: colors.palette.kaiyun_background,
  },
});

export default HomeScreen;
