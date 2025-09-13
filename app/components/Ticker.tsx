import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { SpeakerIcon } from './Icons';
import { colors } from '../theme';

export const Ticker = () => (
    <View style={styles.ticker}>
        <SpeakerIcon color={colors.palette.kaiyun_primaryBlue} width={20} height={20} />
        <View style={styles.tickerContent}>
            <Text>尊敬的客户: 我司FB体育场馆于<Text style={styles.tickerTag}>LIVE 直播中</Text><Text style={styles.tickerTag}>HOT 热门赛事</Text></Text>
        </View>
    </View>
);

const styles = StyleSheet.create({
    ticker: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
        paddingVertical: 10,
        paddingHorizontal: 12,
        fontSize: 12,
    },
    tickerContent: {
        overflow: 'hidden',
    },
    tickerTag: {
        backgroundColor: '#eaf2ff',
        color: colors.palette.kaiyun_primaryBlue,
        paddingVertical: 2,
        paddingHorizontal: 6,
        borderRadius: 4,
        fontWeight: '500',
        marginHorizontal: 4,
    },
});
