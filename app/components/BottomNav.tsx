import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { HomeIcon, GiftIcon, HeadphonesIcon, SponsorIcon, UserIcon } from './Icons';
import { colors } from '../theme';

const navItems = [
    { name: '首页', icon: HomeIcon },
    { name: '优惠', icon: GiftIcon },
    { name: '客服', icon: HeadphonesIcon },
    { name: '赞助', icon: SponsorIcon },
    { name: '我的', icon: UserIcon },
];

export const BottomNav = () => {
    const [activeItem, setActiveItem] = useState('首页');

    return (
        <View style={styles.bottomNav}>
            {navItems.map(item => {
                const isActive = activeItem === item.name;
                const Icon = item.icon;
                return (
                    <TouchableOpacity
                        key={item.name}
                        style={styles.bottomNavItem}
                        onPress={() => setActiveItem(item.name)}
                    >
                        <Icon color={isActive ? colors.palette.kaiyun_primaryBlue : colors.palette.kaiyun_textLight} />
                        <Text style={[styles.bottomNavItemText, isActive && styles.activeBottomNavItemText]}>{item.name}</Text>
                    </TouchableOpacity>
                )
            })}
        </View>
    );
};

const styles = StyleSheet.create({
    bottomNav: {
        flexDirection: 'row',
        justifyContent: 'space-around',
        backgroundColor: colors.palette.kaiyun_white,
        // boxShadow: '0 -2px 5px rgba(0, 0, 0, 0.05)',
        paddingVertical: 8,
        borderTopWidth: 1,
        borderTopColor: colors.palette.kaiyun_border,
    },
    bottomNavItem: {
        flexDirection: 'column',
        alignItems: 'center',
        gap: 4,
    },
    bottomNavItemText: {
        fontSize: 11,
        color: colors.palette.kaiyun_textLight,
    },
    activeBottomNavItemText: {
        color: colors.palette.kaiyun_primaryBlue,
    },
});
