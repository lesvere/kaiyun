import React from 'react';
import { View, StyleSheet } from 'react-native';
import { SideNav } from './SideNav';
import { ContentCards } from './ContentCards';

export const MainContent = () => (
    <View style={styles.mainContent}>
        <SideNav />
        <ContentCards />
    </View>
);

const styles = StyleSheet.create({
    mainContent: {
        flexDirection: 'row',
        paddingVertical: 16,
        paddingHorizontal: 12,
        gap: 10,
    },
});
