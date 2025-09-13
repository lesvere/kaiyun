import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { SearchIcon, ChatIcon } from './Icons';
import { colors } from '../theme';

export const Header = () => (
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
            <SearchIcon color={colors.palette.kaiyun_textLight} />
            <ChatIcon color={colors.palette.kaiyun_textLight} />
        </View>
    </View>
);

const styles = StyleSheet.create({
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: 12,
        backgroundColor: colors.palette.kaiyun_white,
    },
    headerLogo: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
    },
    headerLogoIcon: {
        width: 30,
        height: 30,
        backgroundColor: colors.palette.kaiyun_primaryBlue,
        borderRadius: 15,
        justifyContent: 'center',
        alignItems: 'center',
    },
    headerLogoIconText: {
        color: 'white',
        fontWeight: 'bold',
        fontSize: 16,
    },
    headerLogoText: {

    },
    headerTitle: {
        fontSize: 16,
        color: colors.palette.kaiyun_primaryBlue,
    },
    headerSubtitle: {
        fontSize: 12,
        color: colors.palette.kaiyun_textLight,
    },
    headerInfo: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 10,
    },
    headerDomain: {
        color: colors.palette.kaiyun_textLight,
        fontSize: 12,
    },
});
