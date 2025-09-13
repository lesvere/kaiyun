import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { SportsIcon, LiveIcon, ChessIcon, EsportsIcon, LotteryIcon, SlotsIcon, EntertainmentIcon } from './Icons';
import { colors } from '../theme';

const navItems = [
    { name: '体育', icon: SportsIcon },
    { name: '真人', icon: LiveIcon },
    { name: '棋牌', icon: ChessIcon },
    { name: '电竞', icon: EsportsIcon },
    { name: '彩票', icon: LotteryIcon },
    { name: '电子', icon: SlotsIcon },
    { name: '娱乐', icon: EntertainmentIcon },
];

export const SideNav = () => {
    const [activeItem, setActiveItem] = useState('体育');

    return (
        <View style={styles.sideNav}>
            {navItems.map(item => {
                const isActive = activeItem === item.name;
                const Icon = item.icon;
                return (
                    <TouchableOpacity
                        key={item.name}
                        style={[styles.sideNavItem, isActive && styles.activeSideNavItem]}
                        onPress={() => setActiveItem(item.name)}
                    >
                        <View style={[styles.sideNavIconContainer, isActive && styles.activeSideNavIconContainer]}>
                            <Icon color={isActive ? 'white' : colors.palette.kaiyun_textPrimary} width={28} height={28} />
                        </View>
                        <Text style={[styles.sideNavItemText, isActive && styles.activeSideNavItemText]}>{item.name}</Text>
                    </TouchableOpacity>
                )
            })}
        </View>
    );
};

const styles = StyleSheet.create({
    sideNav: {
        flexDirection: 'column',
        gap: 8,
        flexShrink: 0,
    },
    sideNavItem: {
        flexDirection: 'column',
        alignItems: 'center',
        gap: 6,
        paddingVertical: 8,
        paddingHorizontal: 4,
        borderRadius: 12,
        width: 60,
    },
    activeSideNavItem: {
        backgroundColor: '#f0f6ff',
    },
    sideNavIconContainer: {
        width: 48,
        height: 48,
        backgroundColor: '#f7f8fa',
        borderRadius: 12,
        justifyContent: 'center',
        alignItems: 'center',
    },
    activeSideNavIconContainer: {
        backgroundColor: colors.palette.kaiyun_activeIconBg,
        // boxShadow: '0 4px 8px rgba(58, 127, 255, 0.3)', // shadow in RN is different
    },
    sideNavItemText: {
        fontSize: 13,
        color: colors.palette.kaiyun_textLight,
    },
    activeSideNavItemText: {
        fontWeight: '700',
        color: colors.palette.kaiyun_primaryBlue,
    },
});
