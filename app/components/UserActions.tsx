import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { DepositIcon, TransferIcon, WithdrawIcon, VipIcon, PromoteIcon } from './Icons';
import { colors } from '../theme';

const actions = [
    { name: '存款', icon: <DepositIcon color="white" /> },
    { name: '转账', icon: <TransferIcon color="white" /> },
    { name: '取款', icon: <WithdrawIcon color="white" /> },
    { name: 'VIP', icon: <VipIcon color="white" /> },
    { name: '推广', icon: <PromoteIcon color="white" /> },
];

export const UserActions = () => {
    return (
        <View style={styles.userActions}>
            <View style={styles.userInfo}>
                <Text style={styles.userInfoText}>您还未登录</Text>
                <Text style={styles.userInfoSubtext}>登录/注册后查看</Text>
            </View>
            <View style={styles.actionButtons}>
                {actions.map(action => (
                    <View style={styles.actionButton} key={action.name}>
                        <View style={styles.actionButtonIcon}>{action.icon}</View>
                        <Text style={styles.actionButtonText}>{action.name}</Text>
                    </View>
                ))}
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    userActions: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingVertical: 10,
        paddingHorizontal: 12,
    },
    userInfo: {},
    userInfoText: {
        fontSize: 16,
        fontWeight: '500',
    },
    userInfoSubtext: {
        fontSize: 12,
        color: colors.palette.kaiyun_textSecondary,
    },
    actionButtons: {
        flexDirection: 'row',
        gap: 4,
    },
    actionButton: {
        flexDirection: 'column',
        alignItems: 'center',
        gap: 4,
        width: 50,
    },
    actionButtonIcon: {
        width: 40,
        height: 40,
        backgroundColor: colors.palette.kaiyun_iconBg,
        borderRadius: 10,
        justifyContent: 'center',
        alignItems: 'center',
    },
    actionButtonText: {
        fontSize: 12,
        color: colors.palette.kaiyun_textLight,
    },
});
